//  ARCompositorEngine.swift
//  User-Side-App
//  Handles the FaceTime-filter style compositing pipeline per frame:
//    1. Mirror camera (selfie flip)
//    2. Render clothing in body-tracked position (Vision coords  CIImage coords)
//    3. Blend person segmentation mask ON TOP so arms appear in FRONT of the shirt
//  This runs entirely on the video capture queue and produces finished UIImages
//  at ~30 fps.  No Metal view needed  CIContext uses a Metal device internally.

import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

final class ARCompositorEngine {

    // MARK: - State (touched only on video queue)

    private var pose = BodyPoseData()
    private var clothingCI: CIImage?
    private var clothingItem: ClothingItem?

    // Metal-backed context for GPU-accelerated compositing
    private let ciContext: CIContext = {
        if let device = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        }
        return CIContext(options: [.useSoftwareRenderer: false])
    }()

    // MARK: - Public API

    /// Call whenever the user selects a new clothing item.
    func setClothing(image: UIImage?, item: ClothingItem?) {
        clothingCI = image.flatMap { CIImage(image: $0) }
        clothingItem = item
    }

    ///  Main entry point  call from captureOutput on the video queue.
    ///  Returns the finished UIImage (camera + clothing + person-foreground blended).
    func process(
        pixelBuffer: CVPixelBuffer,
        poseObservation: VNHumanBodyPoseObservation?,
        maskBuffer: CVPixelBuffer?
    ) -> (image: UIImage?, bodyPose: BodyPoseData) {

        // 1. Update smoothed body pose (state is on this queue)
        if let obs = poseObservation {
            pose.update(from: obs)
        } else {
            pose.detected = false
        }

        let bufW = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let bufH = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let extent = CGRect(x: 0, y: 0, width: bufW, height: bufH)

        // 2. Base camera CIImage  (portrait after videoRotationAngle=90)
        let cameraCI = CIImage(cvPixelBuffer: pixelBuffer)

        // 3. Selfie mirror  flip horizontally so it looks like a mirror
        //    The data-output buffer is NOT mirrored by AVFoundation,
        //    so we mirror here ourselves.
        let mirrorTx = CGAffineTransform(scaleX: -1, y: 1)
                         .translatedBy(x: -bufW, y: 0)
        let mirroredCamera = cameraCI.transformed(by: mirrorTx).cropped(to: extent)

        // 4. If there is no clothing or body, just return the mirrored camera frame
        guard let clothingCI, let item = clothingItem, pose.detected else {
            return (render(mirroredCamera, extent: extent), pose)
        }

        // 5. Compute the affine transform that places clothing on the body
        //    (calculated in the ORIGINAL, pre-mirror CIImage space)
        let clothingTransform = computeClothingTransform(
            item: item,
            clothing: clothingCI,
            bufSize: CGSize(width: bufW, height: bufH)
        )

        // 6. Position the clothing in original space, then mirror it to match camera
        let positionedClothing = clothingCI
            .transformed(by: clothingTransform)
            .cropped(to: extent)
        let mirroredClothing = positionedClothing
            .transformed(by: mirrorTx)
            .cropped(to: extent)

        // 7. Person segmentation mask refinement
        //    Scale and mirror the segmentation mask to match the camera feed.
        let maskCI: CIImage? = {
            guard let maskBuf = maskBuffer else { return nil }
            var mask = CIImage(cvPixelBuffer: maskBuf)
            let maskExtent = mask.extent
            let scaleX = bufW / maskExtent.width
            let scaleY = bufH / maskExtent.height
            mask = mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY)).cropped(to: extent)
            return mask.transformed(by: mirrorTx).cropped(to: extent)
        }()

        // 8. Composite: Camera -> Clothing (Clipped by Person Mask)
        //    We draw the clothes OVER the camera, but only where the person silhouette is.
        //    This prevents the clothes from "bleeding" into the real-world background.
        let finalImage: CIImage = {
            if let mask = maskCI {
                // Feather the mask for softer edges
                let featheredMask = mask.applyingGaussianBlur(sigma: 3.0).cropped(to: extent)

                // First, composite the clothing OVER the camera background
                let clothingOnCam = mirroredClothing.composited(over: mirroredCamera)

                // Then, use the person mask to show:
                // - Clothing + Camera (where person is)
                // - Original Camera (where background is)
                let blend = CIFilter.blendWithMask()
                blend.inputImage = clothingOnCam
                blend.backgroundImage = mirroredCamera
                blend.maskImage = featheredMask
                return blend.outputImage?.cropped(to: extent) ?? mirroredCamera
            } else {
                // Fallback if no mask: just draw clothing over camera
                return mirroredClothing.composited(over: mirroredCamera)
            }
        }()

        return (render(finalImage, extent: extent), pose)
    }

    // MARK: - Clothing Transform
    // Computes the CGAffineTransform that maps the clothing CIImage
    // (which starts at origin, clothingW  clothingH) into the buffer's
    // coordinate space (bottom-left origin, bufW  bufH).
    // Vision coords are normalized [0,1] with bottom-left origin.
    // After videoRotationAngle=90 the buffer IS portrait, so Vision x/y
    // match the portrait buffer dimensions directly.
    // The body-pose stored in `pose.normalized` already has the X-mirror
    // baked in (toCapture with mirror:true), so convert back:
    //   ciX = (1 - captureX) * bufW   = visionX * bufW
    //   ciY = (1 - captureY) * bufH   = visionY * bufH

    private func ciPoint(_ capturePoint: CGPoint, bufW: CGFloat, bufH: CGFloat) -> CGPoint {
        CGPoint(x: (1 - capturePoint.x) * bufW, y: (1 - capturePoint.y) * bufH)
    }

    private func computeClothingTransform(
        item: ClothingItem,
        clothing: CIImage,
        bufSize: CGSize
    ) -> CGAffineTransform {
        let bufW = bufSize.width, bufH = bufSize.height
        let norm = pose.normalized
        let cW = clothing.extent.width, cH = clothing.extent.height

        switch item.overlayAnchor {

        case .torso, .arms:
            guard norm.leftShoulder != .zero, norm.rightShoulder != .zero else { return .identity }

            let lSh = ciPoint(norm.leftShoulder, bufW: bufW, bufH: bufH)
            let rSh = ciPoint(norm.rightShoulder, bufW: bufW, bufH: bufH)

            // Width: distance between shoulders  sleeve multiplier
            let shoulderDist = hypot(rSh.x - lSh.x, rSh.y - lSh.y)
            let targetW = shoulderDist * 1.85 * item.defaultScale
            let scaleX = targetW / cW

            // Hip center for torso height
            let hipCenter: CGPoint
            if norm.leftHip != .zero, norm.rightHip != .zero {
                let lH = ciPoint(norm.leftHip, bufW: bufW, bufH: bufH)
                let rH = ciPoint(norm.rightHip, bufW: bufW, bufH: bufH)
                hipCenter = CGPoint(x: (lH.x + rH.x) / 2, y: (lH.y + rH.y) / 2)
            } else {
                // Estimate hips ~1.2 shoulder-widths below shoulders
                let shCenter = CGPoint(x: (lSh.x + rSh.x) / 2, y: (lSh.y + rSh.y) / 2)
                hipCenter = CGPoint(x: shCenter.x, y: shCenter.y - shoulderDist * 1.2)
            }
            let shCenter = CGPoint(x: (lSh.x + rSh.x) / 2, y: (lSh.y + rSh.y) / 2)
            let torsoDist = hypot(hipCenter.x - shCenter.x, hipCenter.y - shCenter.y)
            let targetH = torsoDist * 1.5 * item.defaultScale
            let scaleY = targetH / cH

            // Rotation = shoulder line angle (CIImage: y grows upward  same as math y)
            let angle = atan2(rSh.y - lSh.y, rSh.x - lSh.x)

            // Center of shirt: shoulder midpoint, nudged slightly downward in CIImage
            // (In CIImage, -y moves DOWN in the image = below the collar line)
            let dropY = targetH * 0.1
            let center = CGPoint(x: shCenter.x, y: shCenter.y - dropY)

            return makeTransform(center: center, scaleX: scaleX, scaleY: scaleY,
                                 angle: angle, imageSize: CGSize(width: cW, height: cH))

        case .wrist:
            let wristNorm = norm.leftWrist != .zero ? norm.leftWrist : norm.rightWrist
            guard wristNorm != .zero else { return .identity }
            let wristCI = ciPoint(wristNorm, bufW: bufW, bufH: bufH)

            let shDist: CGFloat
            if norm.leftShoulder != .zero, norm.rightShoulder != .zero {
                let lSh = ciPoint(norm.leftShoulder, bufW: bufW, bufH: bufH)
                let rSh = ciPoint(norm.rightShoulder, bufW: bufW, bufH: bufH)
                shDist = hypot(rSh.x - lSh.x, rSh.y - lSh.y)
            } else { shDist = bufW * 0.25 }

            let watchSz = shDist / 4.0 * item.defaultScale
            let sc = watchSz / max(cW, cH)

            return makeTransform(center: wristCI, scaleX: sc, scaleY: sc,
                                 angle: 0, imageSize: CGSize(width: cW, height: cH))

        default:
            return .identity
        }
    }

    /// Build a CIImage transform that places/scales/rotates an image
    /// (starting at (0,0)) so its center lands at `center`.
    private func makeTransform(center: CGPoint,
                               scaleX: CGFloat, scaleY: CGFloat,
                               angle: CGFloat,
                               imageSize: CGSize) -> CGAffineTransform {
        // 1. Move image origin to centre of image
        var t = CGAffineTransform(translationX: -imageSize.width / 2,
                                   y: -imageSize.height / 2)
        // 2. Scale
        t = t.concatenating(CGAffineTransform(scaleX: scaleX, y: scaleY))
        // 3. Rotate
        t = t.concatenating(CGAffineTransform(rotationAngle: angle))
        // 4. Translate to target center
        t = t.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        return t
    }

    // MARK: - Render

    private func render(_ image: CIImage, extent: CGRect) -> UIImage? {
        guard let cgImage = ciContext.createCGImage(image, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func reset() {
        pose.reset()
    }
}
