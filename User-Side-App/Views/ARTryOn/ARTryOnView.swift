//
//  ARTryOnView.swift
//  User-Side-App
//
//  FaceTime-filter-style AR try-on view.
//  ARCompositorEngine produces a composited UIImage every frame
//  (camera + clothing + person segmentation mask) which is displayed
//  full-screen here.  SwiftUI overlays sit on top for UI chrome.
//

import SwiftUI
import AVFoundation
import UIKit

// MARK: - Main View

struct ARTryOnView: View {
    let product: Product
    @State private var viewModel = ARTryOnViewModel()
    @State private var showSearchSheet = false
    @State private var searchQuery = ""
    @State private var showShareSheet = false
    @State private var flashOpacity: Double = 0
    @State private var isInitialized = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // ── Full-screen composited output (camera + clothing + person mask) ──
            if let img = viewModel.displayImage {
                CompositorDisplayView(image: img)
                    .ignoresSafeArea()
            } else {
                loadingView
            }
            
            // ── SwiftUI overlays ──
            VStack {
                topBar
                Spacer()
                if !viewModel.isBodyDetected && isInitialized { bodyGuide }
                Spacer()
                bottomControls
            }
            
            if case .error(let e) = viewModel.state { errorOverlay(e) }
            
            // Camera-flash effect on capture
            Color.white.opacity(flashOpacity).ignoresSafeArea().allowsHitTesting(false)
            
            // Captured photo review sheet
            if viewModel.showCapturedPhoto, let photo = viewModel.capturedPhoto {
                capturedPhotoOverlay(photo)
            }
        }
        .task {
            await viewModel.initializeCamera()
            await viewModel.loadClothingItem(product)
            isInitialized = true
        }
        .onDisappear { viewModel.reset() }
        .sheet(isPresented: $showSearchSheet) {
            ClothingSearchSheet(viewModel: viewModel, searchQuery: $searchQuery) {
                Task { await viewModel.searchOnlineClothing(query: searchQuery) }
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showShareSheet) {
            if let p = viewModel.capturedPhoto { ShareSheet(items: [p]) }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().stroke(AppColors.gold.opacity(0.2), lineWidth: 3).frame(width: 56, height: 56)
                Circle().trim(from: 0, to: 0.3).stroke(AppColors.gold, lineWidth: 3)
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                    .modifier(SpinModifier())
            }
            Text("INITIALIZING AR")
                .font(.caption).fontWeight(.bold).tracking(3).foregroundStyle(AppColors.gold)
        }
    }
    
    private var bodyGuide: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
                    .foregroundStyle(AppColors.gold.opacity(0.3))
                    .frame(width: 160, height: 290)
                    .modifier(PulseModifier())
                Image(systemName: "figure.stand")
                    .font(.system(size: 110, weight: .ultraLight))
                    .foregroundStyle(AppColors.gold.opacity(0.25))
                    .modifier(PulseModifier())
            }
            VStack(spacing: 6) {
                Text("STAND BACK")
                    .font(.caption).fontWeight(.bold).tracking(3).foregroundStyle(AppColors.gold)
                Text("Show your full upper body to the camera")
                    .font(.caption2).foregroundStyle(.white.opacity(0.55)).multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
        .animation(.easeInOut(duration: 0.4), value: viewModel.isBodyDetected)
    }
    
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .padding(12).background(.ultraThinMaterial.opacity(0.8)).clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 6) {
                Text(product.brand)
                    .font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(AppColors.gold)
                Circle().fill(AppColors.gold.opacity(0.4)).frame(width: 3, height: 3)
                Text(product.name)
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.8)).lineLimit(1)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(.ultraThinMaterial.opacity(0.6)).clipShape(Capsule())
            Spacer()
            Button(action: { showSearchSheet = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium)).foregroundStyle(.white)
                    .padding(12).background(.ultraThinMaterial.opacity(0.8)).clipShape(Circle())
            }
        }
        .padding(.horizontal, 20).padding(.top, 60)
    }
    
    private var bottomControls: some View {
        VStack(spacing: 14) {
            if viewModel.isBodyDetected {
                HStack(spacing: 12) { statusPill; Spacer(); confidencePill }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            HStack(spacing: 28) {
                ctrlButton(icon: "arrow.clockwise", label: "Reset") {
                    Task { await viewModel.loadClothingItem(product) }
                }
                captureBtn
                ctrlButton(icon: "tshirt", label: "Browse") { showSearchSheet = true }
            }
        }
        .padding(.bottom, 40)
        .animation(.spring(response: 0.4), value: viewModel.isBodyDetected)
    }
    
    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.green).frame(width: 6, height: 6).modifier(PulseModifier())
            Text("Body Tracking Active")
                .font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(.ultraThinMaterial.opacity(0.5)).clipShape(Capsule())
    }
    
    private var confidencePill: some View {
        let c = viewModel.bodyConfidence
        return HStack(spacing: 4) {
            Image(systemName: c > 0.7 ? "wifi" : c > 0.5 ? "wifi.exclamationmark" : "wifi.slash")
                .font(.system(size: 10))
            Text("\(Int(c * 100))%").font(.system(size: 11, weight: .semibold, design: .monospaced))
        }
        .foregroundStyle(c > 0.7 ? Color.green : c > 0.5 ? Color.orange : Color.red)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(.ultraThinMaterial.opacity(0.5)).clipShape(Capsule())
    }
    
    private func ctrlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(.white)
                Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(.white.opacity(0.7))
            }
            .frame(width: 56, height: 56).background(.ultraThinMaterial.opacity(0.6)).clipShape(Circle())
        }
    }
    
    private var captureBtn: some View {
        Button(action: capturePhoto) {
            ZStack {
                Circle()
                    .stroke(LinearGradient(colors: [AppColors.gold, AppColors.goldLight],
                                          startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 4).frame(width: 72, height: 72)
                Circle().fill(.white).frame(width: 58, height: 58)
                Image(systemName: "camera.fill").font(.system(size: 20)).foregroundStyle(.black)
            }
        }
    }
    
    private func errorOverlay(_ error: ARTryOnError) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50)).foregroundStyle(AppColors.gold)
            VStack(spacing: 8) {
                Text("Camera Issue").font(.headline).foregroundStyle(.white)
                Text(error.localizedDescription)
                    .font(.subheadline).foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            Button(action: { Task { await viewModel.initializeCamera() } }) {
                Text("TRY AGAIN")
                    .font(.subheadline).fontWeight(.bold).tracking(1).foregroundStyle(.black)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(AppColors.gold).clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.85))
    }
    
    private func capturedPhotoOverlay(_ photo: UIImage) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.showCapturedPhoto = false
                            viewModel.capturedPhoto = nil
                        }
                    }) {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white).padding(12)
                            .background(.ultraThinMaterial).clipShape(Circle())
                    }
                    Spacer()
                    Text("CAPTURED").font(.caption).fontWeight(.bold).tracking(3).foregroundStyle(AppColors.gold)
                    Spacer()
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 20)
                
                Image(uiImage: photo).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 20)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                    Button(action: { showShareSheet = true }) {
                        Label("SHARE", systemImage: "square.and.arrow.up")
                            .font(.caption).fontWeight(.bold).tracking(1).foregroundStyle(.black)
                            .padding(.horizontal, 24).padding(.vertical, 14)
                            .background(AppColors.gold).clipShape(Capsule())
                    }
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.showCapturedPhoto = false
                            viewModel.capturedPhoto = nil
                        }
                    }) {
                        Label("SAVE", systemImage: "square.and.arrow.down")
                            .font(.caption).fontWeight(.bold).tracking(1).foregroundStyle(AppColors.gold)
                            .padding(.horizontal, 24).padding(.vertical, 14)
                            .overlay(Capsule().stroke(AppColors.gold, lineWidth: 1.5))
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private func capturePhoto() {
        withAnimation(.easeOut(duration: 0.1)) { flashOpacity = 0.9 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeIn(duration: 0.25)) { flashOpacity = 0 }
        }
        // Grab the current composited display frame as the "photo"
        if let img = viewModel.captureCurrentDisplay() {
            viewModel.capturedPhoto = img
            withAnimation(.spring(response: 0.4)) { viewModel.showCapturedPhoto = true }
        }
    }
}

// MARK: - Compositor Display View
//
// A lightweight UIViewRepresentable that wraps a UIImageView.
// The image is updated at ~30 fps by ViewModel; UIKit handles the display
// efficiently without triggering full SwiftUI layout passes.

struct CompositorDisplayView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        return iv
    }
    
    func updateUIView(_ iv: UIImageView, context: Context) {
        iv.image = image
    }
}

// MARK: - Clothing Search Sheet

struct ClothingSearchSheet: View {
    @Bindable var viewModel: ARTryOnViewModel
    @Binding var searchQuery: String
    let onSearch: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    searchBar
                    if viewModel.isSearching {
                        ProgressView().padding(.top, 60); Spacer()
                    } else if viewModel.searchResults.isEmpty {
                        emptyState
                    } else {
                        resultsGrid
                    }
                }
            }
            .navigationTitle("Find Clothing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppColors.gold)
            TextField("Search for clothing...", text: $searchQuery)
                .foregroundStyle(.white).onSubmit { onSearch() }
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.grayLight)
                }
            }
            Button(action: onSearch) {
                Text("Search").font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(AppColors.background)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(AppColors.gold).clipShape(Capsule())
            }
        }
        .padding(12).background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt").font(.system(size: 60)).foregroundStyle(AppColors.gold.opacity(0.3))
            Text("Search for clothing to try on").font(.headline).foregroundStyle(.white)
            Text("Find shirts, pants, dresses, and more")
                .font(.subheadline).foregroundStyle(AppColors.grayLight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(.top, 60)
    }
    
    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.searchResults) { result in
                    SearchResultCard(result: result) {
                        Task { await viewModel.selectSearchResult(result); dismiss() }
                    }
                }
            }
            .padding(16)
        }
    }
}

struct SearchResultCard: View {
    let result: ClothingSearchResult
    let onSelect: () -> Void
    @State private var loadedImage: UIImage?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    if let img = loadedImage {
                        Image(uiImage: img).resizable().scaledToFit()
                    } else {
                        Rectangle().fill(AppColors.surfaceDark)
                            .overlay(ProgressView().progressViewStyle(.circular))
                    }
                }
                .frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 12))
                Text(result.title).font(.caption).fontWeight(.medium).foregroundStyle(.white).lineLimit(2)
                HStack {
                    Text(result.source).font(.caption2).foregroundStyle(AppColors.grayLight)
                    Spacer()
                    if let price = result.price {
                        Text(price).font(.caption).fontWeight(.semibold).foregroundStyle(AppColors.gold)
                    }
                }
            }
            .padding(8).background(AppColors.surfaceDark).clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .task { loadedImage = try? await ClothingScraperService.shared.downloadAndCacheImage(from: result.imageURL) }
    }
}

// MARK: - Utilities

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

struct SpinModifier: ViewModifier {
    @State private var spinning = false
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(spinning ? 360 : 0))
            .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: spinning)
            .onAppear { spinning = true }
    }
}

struct PulseModifier: ViewModifier {
    @State private var pulsing = false
    func body(content: Content) -> some View {
        content.opacity(pulsing ? 0.35 : 1.0)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

// MARK: - Preview

#Preview {
    ARTryOnView(product: MockData.products[0])
}
