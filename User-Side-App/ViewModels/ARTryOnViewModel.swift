//
//  ARTryOnViewModel.swift
//  User-Side-App
//
//  Drives the AR Try-On experience.
//  Key changes vs previous version:
//   • Publishes `displayImage` — the fully-composited (camera+clothing+mask) UIImage at 30 fps
//   • Falls back to a hardcoded web URL when the local product asset doesn't exist
//   • Sets videoRotationAngle = 90 so Vision sees a portrait buffer (fixes coordinate system)
//   • Does NOT mirror the data-output buffer — ARCompositorEngine handles the selfie flip
//

import Foundation
import SwiftUI
import AVFoundation
import Vision

@Observable
final class ARTryOnViewModel: NSObject {
    
    override init() { super.init() }
    
    // MARK: - Observed State
    
    var state: ARTryOnState = .idle
    var currentClothingItem: ClothingItem?
    var bodyPose: BodyPoseData = BodyPoseData()
    
    /// Fully composited frame: camera + clothing + person mask. Updated at ~30 fps.
    /// Display this full-screen to get the FaceTime-filter look.
    var displayImage: UIImage?
    
    var searchResults: [ClothingSearchResult] = []
    var isSearching: Bool = false
    var errorMessage: String?
    var capturedPhoto: UIImage?
    var showCapturedPhoto: Bool = false
    
    var isBodyDetected: Bool { bodyPose.detected }
    var bodyConfidence: Float { bodyPose.confidence }
    
    // MARK: - Private
    
    private(set) var session: AVCaptureSession?
    private let videoQueue = DispatchQueue(label: "com.luxe.artryon.video", qos: .userInteractive)
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    private var segmentationRequest: VNGeneratePersonSegmentationRequest?
    private let compositor = ARCompositorEngine()
    
    private var lastFrameTime: CFTimeInterval = 0
    private let frameInterval: CFTimeInterval = 1.0 / 30.0
    
    // MARK: - Fallback Images
    // Loaded once from the web when the local asset doesn't exist.
    // Using stable Pexels CDN URLs (no auth required).
    private enum FallbackURL {
        static let tshirt = URL(string: "https://images.pexels.com/photos/2294342/pexels-photo-2294342.jpeg?auto=compress&cs=tinysrgb&w=600")!
        static let watch  = URL(string: "https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg?auto=compress&cs=tinysrgb&w=400")!
        static let shoes  = URL(string: "https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=400")!
    }
    
    // MARK: - Camera Setup
    
    func initializeCamera() async {
        state = .initializing
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:           await setupCamera()
        case .notDetermined:
            if await AVCaptureDevice.requestAccess(for: .video) { await setupCamera() }
            else { state = .error(.permissionDenied) }
        default: state = .error(.permissionDenied)
        }
    }
    
    private func setupCamera() async {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else {
            state = .error(.cameraNotAvailable)
            return
        }
        captureSession.addInput(input)
        
        // ── Video output (no mirroring — compositor does the selfie flip itself) ──
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: videoQueue)
        output.alwaysDiscardsLateVideoFrames = true
        
        guard captureSession.canAddOutput(output) else {
            state = .error(.cameraNotAvailable)
            return
        }
        captureSession.addOutput(output)
        
        if let conn = output.connection(with: .video) {
            // Rotate to portrait so pixel buffer is portrait-sized.
            // This means Vision body coords are in portrait space — no rotation offset.
            if conn.isVideoRotationAngleSupported(90) {
                conn.videoRotationAngle = 90
            }
            // Intentionally NOT mirroring here — compositor mirrors the CIImage instead.
        }
        
        // ── Person segmentation for arm-occlusion effect ──
        let seg = VNGeneratePersonSegmentationRequest()
        seg.qualityLevel = .balanced
        seg.outputPixelFormat = kCVPixelFormatType_OneComponent8
        segmentationRequest = seg
        
        self.session = captureSession
        
        await MainActor.run { state = .cameraReady }
        DispatchQueue.global(qos: .userInitiated).async { captureSession.startRunning() }
    }
    
    func startSession() {
        guard let session, !session.isRunning else { return }
        state = .searchingForBody
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }
    
    func stopSession() {
        guard let session, session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { session.stopRunning() }
        state = .idle
    }
    
    // MARK: - Clothing Loading
    
    func loadClothingItem(_ product: Product) async {
        let item = ClothingItem.from(product: product)
        await MainActor.run { currentClothingItem = item }
        
        let image = await resolveImage(for: product, item: item)
        let processed = await GarmentProcessor.shared.processGarmentImage(
            image, cacheKey: product.id.uuidString)
        
        await MainActor.run {
            compositor.setClothing(image: processed, item: item)
            state = .applyingClothing
        }
    }
    
    /// Tries local asset first, falls back to the web.
    private func resolveImage(for product: Product, item: ClothingItem) async -> UIImage {
        // 1. Try local asset
        if let local = UIImage(named: product.imageName) { return local }
        
        // 2. Try product URL (if set)
        if let url = item.imageURL,
           let downloaded = try? await ClothingScraperService.shared.downloadAndCacheImage(from: url) {
            return downloaded
        }
        
        // 3. Category-specific web fallback
        let fallbackURL: URL
        switch item.category {
        case .top, .bottom, .dress: fallbackURL = FallbackURL.tshirt
        case .shoes:                fallbackURL = FallbackURL.shoes
        case .accessory where item.overlayAnchor == .wrist: fallbackURL = FallbackURL.watch
        default:                    fallbackURL = FallbackURL.tshirt
        }
        
        if let img = try? await ClothingScraperService.shared.downloadAndCacheImage(from: fallbackURL) {
            return img
        }
        
        // 4. Last resort: solid colour placeholder
        return generatePlaceholder(for: item)
    }
    
    /// Draws a simple coloured rectangle as an ultra-safe fallback.
    private func generatePlaceholder(for item: ClothingItem) -> UIImage {
        let size = CGSize(width: 400, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemBlue.withAlphaComponent(0.7).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 28, weight: .bold)
            ]
            let text = item.name
            let ts = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (size.width - ts.width)/2,
                                  y: (size.height - ts.height)/2),
                      withAttributes: attrs)
        }
    }
    
    func loadClothingItem(_ clothingItem: ClothingItem) async {
        await MainActor.run { currentClothingItem = clothingItem }
        
        let image: UIImage
        if let name = clothingItem.localImageName, let local = UIImage(named: name) {
            image = local
        } else if let url = clothingItem.imageURL,
                  let downloaded = try? await ClothingScraperService.shared.downloadAndCacheImage(from: url) {
            image = downloaded
        } else {
            image = generatePlaceholder(for: clothingItem)
        }
        
        let processed = await GarmentProcessor.shared.processGarmentImage(
            image, cacheKey: clothingItem.id.uuidString)
        
        await MainActor.run {
            compositor.setClothing(image: processed, item: clothingItem)
            state = .applyingClothing
        }
    }
    
    // MARK: - Search
    
    func searchOnlineClothing(query: String) async {
        await MainActor.run { isSearching = true; searchResults = [] }
        do {
            let results = try await ClothingScraperService.shared.searchClothingImages(
                query: query, category: currentClothingItem?.category)
            await MainActor.run { self.searchResults = results; self.isSearching = false }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription; self.isSearching = false }
        }
    }
    
    func selectSearchResult(_ result: ClothingSearchResult) async {
        await MainActor.run { isSearching = true }
        do {
            let img = try await ClothingScraperService.shared.downloadAndCacheImage(from: result.imageURL)
            let processed = await GarmentProcessor.shared.processGarmentImage(
                img, cacheKey: result.imageURL.absoluteString)
            let newItem = ClothingItem(
                name: result.title, brand: result.source,
                imageURL: result.imageURL,
                category: currentClothingItem?.category ?? .top)
            await MainActor.run {
                self.currentClothingItem = newItem
                compositor.setClothing(image: processed, item: newItem)
                self.isSearching = false
                self.state = .applyingClothing
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription; self.isSearching = false }
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        stopSession()
        currentClothingItem = nil
        displayImage = nil
        capturedPhoto = nil
        showCapturedPhoto = false
        bodyPose.reset()
        compositor.reset()
        searchResults = []
        errorMessage = nil
        state = .idle
    }
    
    // MARK: - Screenshot
    
    func captureCurrentDisplay() -> UIImage? { displayImage }
}

// MARK: - Capture Output Delegate

extension ARTryOnViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let now = CACurrentMediaTime()
        guard now - lastFrameTime >= frameInterval else { return }
        lastFrameTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Vision handler — orientation .up is correct here because we set
        // videoRotationAngle = 90 on the output connection, so the buffer IS portrait
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .up,
                                            options: [:])
        var requests: [VNRequest] = [bodyPoseRequest]
        if let seg = segmentationRequest { requests.append(seg) }
        try? handler.perform(requests)
        
        let poseObservation = bodyPoseRequest.results?.first
        let maskBuffer = segmentationRequest?.results?.first?.pixelBuffer
        
        // Composite frame on video queue (GPU-accelerated via Metal CIContext)
        let (composited, updatedPose) = compositor.process(
            pixelBuffer: pixelBuffer,
            poseObservation: poseObservation,
            maskBuffer: maskBuffer
        )
        
        // Push display image + pose to main thread
        DispatchQueue.main.async {
            self.displayImage = composited
            self.bodyPose = updatedPose
            
            if updatedPose.detected {
                if self.state == .cameraReady || self.state == .searchingForBody {
                    self.state = .bodyDetected
                }
            } else if self.state == .bodyDetected {
                self.state = .searchingForBody
            }
        }
    }
}
