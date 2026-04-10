//
//  BannerCarousel.swift
//  User-Side-App
//
//  Auto-scrolling promotional banner carousel for LUXE
//

import SwiftUI
import Combine

struct BannerCarousel: View {
    let banners: [PromoBanner]
    @State private var currentIndex = 0
    @Environment(NavigationManager.self) private var navManager
    
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            // Banner TabView
            TabView(selection: $currentIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    BannerCard(banner: banner)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 20)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    currentIndex = (currentIndex + 1) % max(banners.count, 1)
                }
            }
            
            // Custom page indicators
            HStack(spacing: 6) {
                ForEach(0..<banners.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? AppColors.gold : AppColors.grayDark)
                        .frame(
                            width: index == currentIndex ? 24 : 8,
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
        }
    }
}

// MARK: - Individual Banner Card

struct BannerCard: View {
    let banner: PromoBanner
    @Environment(NavigationManager.self) private var navManager
    
    var body: some View {
        ZStack {
            // Background image
            Image(banner.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipped()
            
            // Dark overlay for text readability
            LinearGradient(
                colors: [
                    .black.opacity(0.8),
                    .black.opacity(0.2),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            // Content
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Decorative line
                    Rectangle()
                        .fill(AppColors.gold)
                        .frame(width: 30, height: 2)
                    
                    Text(banner.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    
                    Text(banner.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                    
                    Spacer()
                    
                    GoldButton(title: banner.ctaText, isCompact: true) {
                        navManager.navigateToShop()
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        BannerCarousel(banners: MockData.banners)
    }
}
