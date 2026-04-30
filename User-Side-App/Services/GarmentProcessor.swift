//  GarmentProcessor.swift
//  User-Side-App
//  Service for preparing clothing images for AR overlay
//  background removal, edge feathering, and caching.

import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

final class GarmentProcessor {

    static let shared = GarmentProcessor()

    private let context = CIContext(options: [.useSoftwareRenderer: false])
    private var processedCache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "com.luxe.garment.processor", qos: .userInitiated)

    private init() {}

    // MARK: - Public API

    /// Process a raw garment image for AR overlay:
    /// 1. Remove background (isolate clothing)
    /// 2. Feather edges for natural blending
    /// 3. Cache the result
    func processGarmentImage(_ image: UIImage, cacheKey: String) async -> UIImage {
        // Check cache
        if let cached = processedCache[cacheKey] {
            return cached
        }

        let processed = await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: image)
                    return
                }

                let result = self.removeBackgroundAndFeather(image)
                self.processedCache[cacheKey] = result
                continuation.resume(returning: result)
            }
        }

        return processed
    }

    /// Quick check if we have a cached processed version
    func hasCachedImage(for key: String) -> Bool {
        processedCache[key] != nil
    }

    func clearCache() {
        processedCache.removeAll()
    }

    // MARK: - Background Removal

    private func removeBackgroundAndFeather(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)

        // Try subject-based segmentation first (iOS 17+)
        if let masked = applySubjectMask(to: ciImage, cgImage: cgImage) {
            return featherEdges(masked) ?? UIImage(ciImage: masked)
        }

        // Fallback: try saliency-based removal
        if let saliencyMasked = applySaliencyMask(to: ciImage, cgImage: cgImage) {
            return featherEdges(saliencyMasked) ?? UIImage(ciImage: saliencyMasked)
        }

        // Last resort: return original with some processing
        return image
    }

    /// Uses VNGenerateForegroundInstanceMaskRequest (iOS 17+) to isolate the subject
    private func applySubjectMask(to ciImage: CIImage, cgImage: CGImage) -> CIImage? {
        guard #available(iOS 17.0, *) else { return nil }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let result = request.results?.first else { return nil }

            let maskPixelBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )

            let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)

            // Scale mask to match source image
            let scaleX = ciImage.extent.width / maskCIImage.extent.width
            let scaleY = ciImage.extent.height / maskCIImage.extent.height
            let scaledMask = maskCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            // Apply mask
            let blendFilter = CIFilter.blendWithMask()
            blendFilter.inputImage = ciImage
            blendFilter.backgroundImage = CIImage.empty()
            blendFilter.maskImage = scaledMask

            return blendFilter.outputImage

        } catch {
            return nil
        }
    }

    /// Fallback: Use saliency detection to find the main object
    private func applySaliencyMask(to ciImage: CIImage, cgImage: CGImage) -> CIImage? {
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let result = request.results?.first else { return nil }

            let saliencyMap = result.pixelBuffer
            var maskCIImage = CIImage(cvPixelBuffer: saliencyMap)

            // Scale mask to match source
            let scaleX = ciImage.extent.width / maskCIImage.extent.width
            let scaleY = ciImage.extent.height / maskCIImage.extent.height
            maskCIImage = maskCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            // Threshold the saliency map to create a binary mask
            let thresholdFilter = CIFilter(name: "CIColorMatrix")
            thresholdFilter?.setValue(maskCIImage, forKey: kCIInputImageKey)

            guard let thresholdedMask = thresholdFilter?.outputImage else { return nil }

            // Apply mask
            let blendFilter = CIFilter.blendWithMask()
            blendFilter.inputImage = ciImage
            blendFilter.backgroundImage = CIImage.empty()
            blendFilter.maskImage = thresholdedMask

            return blendFilter.outputImage

        } catch {
            return nil
        }
    }

    // MARK: - Edge Feathering

    /// Apply Gaussian blur to the alpha channel edges for soft blending
    private func featherEdges(_ ciImage: CIImage) -> UIImage? {
        // Extract alpha channel
        let alphaFilter = CIFilter(name: "CIColorMatrix")
        alphaFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        // Zero out RGB, keep alpha
        alphaFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        alphaFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        alphaFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        alphaFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")

        guard let alphaImage = alphaFilter?.outputImage else {
            return renderCIImage(ciImage)
        }

        // Slight blur on the alpha edge
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = alphaImage
        blurFilter.radius = 1.5  // Very subtle feathering

        guard let blurredAlpha = blurFilter.outputImage else {
            return renderCIImage(ciImage)
        }

        // Use blurred alpha as a mask to blend the original onto empty background
        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = ciImage
        blendFilter.backgroundImage = CIImage.empty()
        blendFilter.maskImage = blurredAlpha

        guard let output = blendFilter.outputImage else {
            return renderCIImage(ciImage)
        }

        return renderCIImage(output)
    }

    private func renderCIImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
