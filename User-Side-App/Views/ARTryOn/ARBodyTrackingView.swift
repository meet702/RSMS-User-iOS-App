import SwiftUI
import ARKit
import RealityKit
import AVFoundation

struct ARBodyTrackingView: UIViewRepresentable {
    let session: ARSession
    let clothingEntity: Entity?
    let cameraPosition: AVCaptureDevice.Position

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session = session
        context.coordinator.arView = arView

        runSession(for: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Handle clothing entity changes
        if context.coordinator.clothingEntity != clothingEntity {
            context.coordinator.updateClothingEntity(clothingEntity)
        }

        // Restart session if camera position changes
        if context.coordinator.lastCameraPosition != cameraPosition {
            context.coordinator.lastCameraPosition = cameraPosition
            runSession(for: uiView)
        }
    }

    private func runSession(for arView: ARView) {
        arView.backgroundColor = .black // Ensure it starts black but with a reference point
        let configuration: ARConfiguration

        if cameraPosition == .back {
            if ARBodyTrackingConfiguration.isSupported {
                let bodyConfig = ARBodyTrackingConfiguration()
                bodyConfig.automaticSkeletonScaleEstimationEnabled = true
                if ARBodyTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                    bodyConfig.frameSemantics.insert(.personSegmentationWithDepth)
                }
                configuration = bodyConfig
            } else {
                print(" ARBodyTrackingConfiguration not supported on this device.")
                let worldConfig = ARWorldTrackingConfiguration()
                if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
                    worldConfig.frameSemantics.insert(.personSegmentation)
                }
                configuration = worldConfig
            }
        } else {
            if ARFaceTrackingConfiguration.isSupported {
                let faceConfig = ARFaceTrackingConfiguration()
                if ARFaceTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
                    faceConfig.frameSemantics.insert(.personSegmentation)
                }
                configuration = faceConfig
            } else {
                print(" ARFaceTrackingConfiguration not supported on this device.")
                configuration = ARWorldTrackingConfiguration()
            }
        }

        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var bodyAnchor: ARBodyAnchor?
        var clothingEntity: Entity?
        var anchorEntity: AnchorEntity?
        var lastCameraPosition: AVCaptureDevice.Position?

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let bodyAnchor = anchor as? ARBodyAnchor {
                    self.bodyAnchor = bodyAnchor
                    setupClothing(for: bodyAnchor)
                }
            }
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let bodyAnchor = anchor as? ARBodyAnchor {
                    self.bodyAnchor = bodyAnchor
                    updateJointAnchors(for: bodyAnchor)
                }
            }
        }

        func updateClothingEntity(_ newEntity: Entity?) {
            clothingEntity?.removeFromParent()
            clothingEntity = newEntity

            if let entity = newEntity, let anchor = anchorEntity {
                anchor.addChild(entity)
            }
        }

        private func setupClothing(for bodyAnchor: ARBodyAnchor) {
            guard let arView = arView else { return }

            let anchor = AnchorEntity(anchor: bodyAnchor)
            self.anchorEntity = anchor
            arView.scene.addAnchor(anchor)

            // Placeholder: Load a 3D shirt if it was provided
            // For now, we'll use the entity from the shared state if possible
        }

        private func updateJointAnchors(for bodyAnchor: ARBodyAnchor) {
            guard let clothing = clothingEntity else { return }

            // Map ARKit skeleton joints to our clothing entity if it's a multipart model
            // or simply anchor the whole entity to the 'spine_7' (chest) area.

            let skeleton = bodyAnchor.skeleton
            if let rootTransform = skeleton.modelTransform(for: .root) {
                clothing.setTransformMatrix(rootTransform, relativeTo: anchorEntity)
            }
        }
    }
}
