//  ARTryOnModels.swift
//  User-Side-App
//  Models for AR Clothing Try-On feature
//  Stores RAW normalized Vision coordinates so the overlay
//  can use AVCaptureVideoPreviewLayer.layerPointConverted()
//  for pixel-perfect Snapchat-style positioning.

import Foundation
import Vision
import CoreGraphics

// MARK: - Clothing Item

struct ClothingItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let brand: String
    let imageURL: URL?
    let localImageName: String?
    let category: ClothingCategory
    let overlayAnchor: BodyAnchorPoint
    let defaultScale: CGFloat
    let opacity: CGFloat

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        imageURL: URL? = nil,
        localImageName: String? = nil,
        category: ClothingCategory,
        overlayAnchor: BodyAnchorPoint = .torso,
        defaultScale: CGFloat = 1.0,
        opacity: CGFloat = 1.0
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.imageURL = imageURL
        self.localImageName = localImageName
        self.category = category
        self.overlayAnchor = overlayAnchor
        self.defaultScale = defaultScale
        self.opacity = opacity
    }

    static func from(product: Product, imageURL: URL? = nil) -> ClothingItem {
        let category: ClothingCategory
        let defaultScale: CGFloat
        let anchor: BodyAnchorPoint
        let opacity: CGFloat

        switch product.category {
        case "Watches":
            category = .accessory
            anchor = .wrist
            defaultScale = 0.15
            opacity = 1.0
        case "Fashion":
            if product.name.lowercased().contains("sneaker") || product.name.lowercased().contains("shoe") {
                category = .shoes
                anchor = .feet
                defaultScale = 0.5
                opacity = 0.95
            } else if product.name.lowercased().contains("belt") {
                category = .accessory
                anchor = .torso
                defaultScale = 0.4
                opacity = 0.95
            } else if product.name.lowercased().contains("jeans") || product.name.lowercased().contains("pant") || product.name.lowercased().contains("trouser") {
                category = .bottom
                anchor = .legs
                defaultScale = 0.8
                opacity = 0.9
            } else if product.name.lowercased().contains("blazer") || product.name.lowercased().contains("jacket") {
                category = .top
                anchor = .torso
                defaultScale = 0.72
                opacity = 0.93
            } else {
                // T-shirts, sweaters, etc.
                category = .top
                anchor = .torso
                defaultScale = 0.68
                opacity = 0.9
            }
        case "Handbags":
            category = .accessory
            anchor = .wrist
            defaultScale = 0.3
            opacity = 1.0
        case "Shoes":
            category = .shoes
            anchor = .feet
            defaultScale = 0.5
            opacity = 0.95
        case "Accessories":
            category = .accessory
            anchor = .wrist
            defaultScale = 0.25
            opacity = 1.0
        default:
            category = .accessory
            anchor = .wrist
            defaultScale = 0.3
            opacity = 1.0
        }

        return ClothingItem(
            name: product.name,
            brand: product.brand,
            imageURL: imageURL,
            localImageName: product.imageName,
            category: category,
            overlayAnchor: anchor,
            defaultScale: defaultScale,
            opacity: opacity
        )
    }
}

// MARK: - Enums

enum ClothingCategory: String, CaseIterable, Sendable {
    case top = "Top"
    case bottom = "Bottom"
    case dress = "Dress"
    case shoes = "Shoes"
    case accessory = "Accessory"
    case hat = "Hat"
    case glasses = "Glasses"
    case jewelry = "Jewelry"

    var anchorPoint: BodyAnchorPoint {
        switch self {
        case .top: return .torso
        case .bottom: return .legs
        case .dress: return .torso
        case .shoes: return .feet
        case .accessory: return .wrist
        case .hat: return .head
        case .glasses: return .face
        case .jewelry: return .neck
        }
    }
}

enum BodyAnchorPoint: String, CaseIterable, Sendable {
    case head
    case face
    case neck
    case torso
    case arms
    case wrist
    case legs
    case feet
}

// MARK: - Smoothed Scalar

struct SmoothedFloat: Sendable {
    var value: CGFloat = 0
    private let alpha: CGFloat
    private var initialized = false

    init(initialValue: CGFloat = 0, alpha: CGFloat = 0.3) {
        self.value = initialValue
        self.alpha = alpha
    }

    mutating func update(_ newValue: CGFloat) {
        if !initialized { value = newValue; initialized = true; return }
        value = value + alpha * (newValue - value)
    }

    mutating func reset() { value = 0; initialized = false }
}

// MARK: - Smoothed Point (holds a normalized 0-1 CGPoint)

struct SmoothedPoint: Sendable {
    private(set) var x: CGFloat = 0
    private(set) var y: CGFloat = 0
    private let alpha: CGFloat
    private var initialized = false

    init(alpha: CGFloat = 0.3) { self.alpha = alpha }

    var point: CGPoint { CGPoint(x: x, y: y) }

    mutating func update(_ p: CGPoint) {
        if !initialized { x = p.x; y = p.y; initialized = true; return }
        x = x + alpha * (p.x - x)
        y = y + alpha * (p.y - y)
    }

    mutating func reset() { x = 0; y = 0; initialized = false }
}

// MARK: - Raw Vision Normalized Points
// These are stored in "capture device point" space:
//   x  [0,1] leftright in the device's natural orientation
//   y  [0,1] topbottom
// This is *exactly* the space that
// AVCaptureVideoPreviewLayer.layerPointConverted(fromCaptureDevicePoint:)
// expects, which is how Snapchat/Instagram map body/face points to screen pixels.
// Conversion from Vision (bottom-left origin, front camera mirrored):
//   captureX = 1 - visionX   (flip X for front camera mirror)
//   captureY = 1 - visionY   (flip Y since Vision origin is bottom-left)

struct NormalizedBodyPoints: Sendable {
    var leftShoulder:  CGPoint = .zero
    var rightShoulder: CGPoint = .zero
    var leftHip:       CGPoint = .zero
    var rightHip:      CGPoint = .zero
    var leftWrist:     CGPoint = .zero
    var rightWrist:    CGPoint = .zero
    var leftElbow:     CGPoint = .zero
    var rightElbow:    CGPoint = .zero
    var leftAnkle:     CGPoint = .zero
    var rightAnkle:    CGPoint = .zero
    var nose:          CGPoint = .zero
    var neck:          CGPoint = .zero
    var leftKnee:      CGPoint = .zero
    var rightKnee:     CGPoint = .zero

    // Smoothers
    private var _lShoulder  = SmoothedPoint(alpha: 0.35)
    private var _rShoulder  = SmoothedPoint(alpha: 0.35)
    private var _lHip       = SmoothedPoint(alpha: 0.30)
    private var _rHip       = SmoothedPoint(alpha: 0.30)
    private var _lWrist     = SmoothedPoint(alpha: 0.40)
    private var _rWrist     = SmoothedPoint(alpha: 0.40)
    private var _lElbow     = SmoothedPoint(alpha: 0.35)
    private var _rElbow     = SmoothedPoint(alpha: 0.35)
    private var _lAnkle     = SmoothedPoint(alpha: 0.28)
    private var _rAnkle     = SmoothedPoint(alpha: 0.28)
    private var _nose       = SmoothedPoint(alpha: 0.30)
    private var _neck       = SmoothedPoint(alpha: 0.35)
    private var _lKnee      = SmoothedPoint(alpha: 0.28)
    private var _rKnee      = SmoothedPoint(alpha: 0.28)

    /// Convert a Vision recognised point to capture-device-point space.
    /// - isMirrored: true for front camera (the preview is mirrored so we flip X)
    private func toCapture(_ p: VNRecognizedPoint, mirror: Bool) -> CGPoint {
        let cx = mirror ? (1 - p.x) : p.x
        let cy = 1 - p.y          // Vision origin = bottom-left; capture = top-left
        return CGPoint(x: cx, y: cy)
    }

    mutating func update(from obs: VNHumanBodyPoseObservation) {
        guard let pts = try? obs.recognizedPoints(.all) else { return }

        // Inline each joint update independently.
        // Swift's exclusivity rules disallow taking two &inout references to the
        // same struct simultaneously (even in a nested func), so we expand manually.

        if let p = pts[.leftShoulder],  p.confidence > 0.1 { _lShoulder.update(toCapture(p, mirror: true));  leftShoulder  = _lShoulder.point  }
        if let p = pts[.rightShoulder], p.confidence > 0.1 { _rShoulder.update(toCapture(p, mirror: true));  rightShoulder = _rShoulder.point  }
        if let p = pts[.leftHip],       p.confidence > 0.1 { _lHip.update(toCapture(p, mirror: true));       leftHip       = _lHip.point       }
        if let p = pts[.rightHip],      p.confidence > 0.1 { _rHip.update(toCapture(p, mirror: true));       rightHip      = _rHip.point       }
        if let p = pts[.leftWrist],     p.confidence > 0.1 { _lWrist.update(toCapture(p, mirror: true));     leftWrist     = _lWrist.point     }
        if let p = pts[.rightWrist],    p.confidence > 0.1 { _rWrist.update(toCapture(p, mirror: true));     rightWrist    = _rWrist.point     }
        if let p = pts[.leftElbow],     p.confidence > 0.1 { _lElbow.update(toCapture(p, mirror: true));     leftElbow     = _lElbow.point     }
        if let p = pts[.rightElbow],    p.confidence > 0.1 { _rElbow.update(toCapture(p, mirror: true));     rightElbow    = _rElbow.point     }
        if let p = pts[.leftAnkle],     p.confidence > 0.1 { _lAnkle.update(toCapture(p, mirror: true));     leftAnkle     = _lAnkle.point     }
        if let p = pts[.rightAnkle],    p.confidence > 0.1 { _rAnkle.update(toCapture(p, mirror: true));     rightAnkle    = _rAnkle.point     }
        if let p = pts[.nose],          p.confidence > 0.1 { _nose.update(toCapture(p, mirror: true));       nose          = _nose.point       }
        if let p = pts[.neck],          p.confidence > 0.1 { _neck.update(toCapture(p, mirror: true));       neck          = _neck.point       }
        if let p = pts[.leftKnee],      p.confidence > 0.1 { _lKnee.update(toCapture(p, mirror: true));      leftKnee      = _lKnee.point      }
        if let p = pts[.rightKnee],     p.confidence > 0.1 { _rKnee.update(toCapture(p, mirror: true));      rightKnee     = _rKnee.point      }
    }

    mutating func reset() {
        _lShoulder.reset(); _rShoulder.reset()
        _lHip.reset();      _rHip.reset()
        _lWrist.reset();    _rWrist.reset()
        _lElbow.reset();    _rElbow.reset()
        _lAnkle.reset();    _rAnkle.reset()
        _nose.reset();      _neck.reset()
        _lKnee.reset();     _rKnee.reset()

        leftShoulder = .zero; rightShoulder = .zero
        leftHip = .zero;      rightHip = .zero
        leftWrist = .zero;    rightWrist = .zero
        leftElbow = .zero;    rightElbow = .zero
        leftAnkle = .zero;    rightAnkle = .zero
        nose = .zero;         neck = .zero
        leftKnee = .zero;     rightKnee = .zero
    }
}

// MARK: - Body Pose Data (used by SwiftUI layer  still holds screen-space values for the guide overlay etc.)

struct BodyPoseData: Sendable {
    /// Raw smoothed normalized capture-device-point coordinates (0-1).
    /// Use these with layerPointConverted() for pixel-perfect positioning.
    var normalized = NormalizedBodyPoints()

    var detected: Bool = false
    var confidence: Float = 0.0

    // Derived shoulder width in normalized units (for sizing the overlay)
    var normalizedShoulderWidth: CGFloat = 0.3
    private var _shoulderWidth = SmoothedFloat(alpha: 0.25)

    // Body tilt angle in radians
    var bodyAngle: CGFloat = 0
    private var _bodyAngle = SmoothedFloat(alpha: 0.30)

    mutating func update(from observation: VNHumanBodyPoseObservation) {
        guard let recognized = try? observation.recognizedPoints(.all) else {
            detected = false
            return
        }

        guard let lS = recognized[.leftShoulder],
              let rS = recognized[.rightShoulder],
              lS.confidence > 0.1,
              rS.confidence > 0.1 else {
            detected = false
            return
        }

        // Update all normalized points
        normalized.update(from: observation)

        // Shoulder width in normalized space (0-1)
        let rawWidth = abs(normalized.rightShoulder.x - normalized.leftShoulder.x)
        _shoulderWidth.update(rawWidth)
        normalizedShoulderWidth = _shoulderWidth.value

        // Body angle  from right to left shoulder in screen coords
        // (after coordinate flip, so we compute from the stored capture-device points)
        let dx = normalized.rightShoulder.x - normalized.leftShoulder.x
        let dy = normalized.rightShoulder.y - normalized.leftShoulder.y
        // Convert to screen-space angle: y axis is flipped in screen vs capture-device in some contexts
        // We negate dy because screen y grows downward, which layerPointConverted already accounts for
        _bodyAngle.update(atan2(dy, dx))
        bodyAngle = _bodyAngle.value

        // Compute confidence
        var total: Float = 0; var count: Float = 0
        for (_, p) in recognized where p.confidence > 0.1 {
            total += p.confidence; count += 1
        }
        confidence = count > 0 ? total / count : 0
        detected = confidence > 0.3
    }

    mutating func reset() {
        normalized.reset()
        _shoulderWidth.reset()
        _bodyAngle.reset()
        normalizedShoulderWidth = 0.3
        bodyAngle = 0
        detected = false
        confidence = 0
    }
}

// MARK: - Other Types

struct TryOnSession: Identifiable, Sendable {
    let id = UUID()
    let clothingItem: ClothingItem
    let timestamp = Date()
}

struct ClothingSearchResult: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let imageURL: URL
    let source: String
    let price: String?
}

enum ARTryOnState: Equatable, Sendable {
    case idle, initializing, cameraReady, searchingForBody, bodyDetected, applyingClothing
    case error(ARTryOnError)

    static func == (lhs: ARTryOnState, rhs: ARTryOnState) -> Bool {
        switch (lhs, rhs) {
        case (.idle,.idle),(.initializing,.initializing),(.cameraReady,.cameraReady),
             (.searchingForBody,.searchingForBody),(.bodyDetected,.bodyDetected),
             (.applyingClothing,.applyingClothing): return true
        case (.error(let a),.error(let b)): return a == b
        default: return false
        }
    }
}

enum ARTryOnError: Error, Equatable, Sendable {
    case cameraNotAvailable, bodyTrackingNotSupported, permissionDenied
    case networkError, imageLoadFailed
    case sessionFailed(String)

    var localizedDescription: String {
        switch self {
        case .cameraNotAvailable:        return "Camera is not available on this device"
        case .bodyTrackingNotSupported:  return "Body tracking requires iPhone 12 or newer"
        case .permissionDenied:          return "Camera permission is required for AR Try-On"
        case .networkError:              return "Unable to connect. Please check your internet connection."
        case .imageLoadFailed:           return "Failed to load clothing image"
        case .sessionFailed(let msg):    return msg
        }
    }
}
