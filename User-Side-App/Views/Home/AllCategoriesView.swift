//
//  AllCategoriesView.swift
//  User-Side-App
//
//  A dedicated, highly stylized masonry grid of all categories.
//

import SwiftUI

struct AllCategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    
    // Split categories into left and right columns for the masonry effect
    private var leftColumn: [Category] {
        categories.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
    }
    
    private var rightColumn: [Category] {
        categories.enumerated().filter { $0.offset % 2 != 0 }.map { $0.element }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGoldBackground()
                
                GeometryReader { proxy in
                    let screenWidth = proxy.size.width
                    // 24pt left padding + 24pt right padding + 28pt center gap = 76pt total horizontal spacing
                    let cardWidth = (screenWidth - 76) / 2
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            Text("Explore Collections")
                                .font(.custom("IowanOldStyle-Roman", size: 32, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.pureWhite)
                                .padding(.top, 20)
                                .padding(.horizontal, 24)
                                .accessibilityAddTraits(.isHeader)
                            
                            // Masonry Grid
                            HStack(alignment: .top, spacing: 28) {
                                // Left Column
                                VStack(spacing: 28) {
                                    ForEach(leftColumn) { category in
                                        MasonryCategoryCard(category: category, isTall: category.name.count % 2 == 0, width: cardWidth)
                                    }
                                }
                                
                                // Right Column (Offset slightly down for authentic masonry feel)
                                VStack(spacing: 28) {
                                    ForEach(rightColumn) { category in
                                        MasonryCategoryCard(category: category, isTall: category.name.count % 2 != 0, width: cardWidth)
                                    }
                                }
                                .padding(.top, 40)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        }
                        // Ensure the VStack takes exactly the screen width to prevent horizontal drift
                        .frame(width: screenWidth, alignment: .leading)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.pureWhite)
                            .padding(10)
                            .background(AppColors.surfaceDark)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

// MARK: - Individual Masonry Card

struct MasonryCategoryCard: View {
    let category: Category
    let isTall: Bool
    let width: CGFloat
    
    // Dynamically map live database category names to the beautiful curated AI assets
    // strict mode: If no relevance is found, return nil to show a clean elegant card instead of a confusingly wrong image.
    private var luxuryBackgroundImage: String? {
        let name = category.name.lowercased()
        if name.contains("watch") || name.contains("time") { return "cat_watches" }
        if name.contains("jewel") || name.contains("ring") || name.contains("bracelet") { return "cat_jewelry" }
        if name.contains("bag") || name.contains("leather") || name.contains("tote") { return "cat_handbags" }
        if name.contains("shoe") || name.contains("sneaker") || name.contains("footwear") { return "cat_shoes" }
        if name.contains("fragrance") || name.contains("perfume") || name.contains("cologne") { return "cat_fragrances" }
        if name.contains("glass") || name.contains("accessor") { return "cat_accessories" }
        if name.contains("fashion") || name.contains("couture") || name.contains("cloth") || name.contains("apparel") { return "cat_fashion" }
        return nil
    }
    
    var body: some View {
        Button(action: {
            // Actions
        }) {
            ZStack(alignment: .bottom) {
                // Dynamic AI Background
                if let bg = luxuryBackgroundImage {
                    Image(bg)
                        .resizable()
                        .scaledToFill()
                } else {
                    AppColors.surfaceDark
                }
                
                // Rich Obsidian Gradient
                LinearGradient(
                    colors: [.black.opacity(0.85), .black.opacity(0.1), .black.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Glassy Inner glow
                UnevenRoundedRectangle(
                    topLeadingRadius: 100, bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16, topTrailingRadius: 100
                )
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Content Layout
                VStack(spacing: 0) {
                    // Floating Jewel Badge
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.6), radius: 6, y: 3)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.pureWhite, AppColors.goldLight],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Editorial Text Layout
                    VStack(spacing: 6) {
                        Text(category.name.uppercased())
                            .font(.system(size: 16, weight: .black, design: .serif))
                            .tracking(2)
                            .foregroundStyle(AppColors.pureWhite)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                        
                        Text("\(category.productCount) ITEMS")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .tracking(1)
                            .foregroundStyle(AppColors.gold)
                    }
                    .padding(.bottom, 28)
                }
            }
            .frame(width: width)
            .frame(height: isTall ? 280 : 230)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 100, bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16, topTrailingRadius: 100
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 100, bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16, topTrailingRadius: 100
                )
                .stroke(
                    LinearGradient(
                        colors: [AppColors.gold.opacity(0.8), AppColors.gold.opacity(0.1), AppColors.gold.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
            .shadow(color: .black.opacity(0.5), radius: 12, y: 8)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("\(category.name) collection, \(category.productCount) items")
        .accessibilityHint("Double tap to view \(category.name) items")
    }
}

#Preview {
    AllCategoriesView(categories: MockData.categories)
        .withLuxePreviewEnvironment()
}
