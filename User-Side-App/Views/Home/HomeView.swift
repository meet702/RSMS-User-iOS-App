//
//  HomeView.swift
//  User-Side-App
//
//  LUXE Home Tab — Main scrollable view
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                
                // MARK: - Header
                headerSection
                
                // MARK: - Search Bar
                HomeSearchBar(searchText: $viewModel.searchText)
                
                // MARK: - Banner Carousel
                BannerCarousel(banners: viewModel.banners)
                
                // MARK: - Categories
                CategorySection(categories: viewModel.categories)
                
                // Gold divider
                goldDivider
                
                // MARK: - New Arrivals
                FeaturedSection(
                    title: "New Arrivals",
                    products: viewModel.newArrivals
                )
                
                // MARK: - Featured Collection
                FeaturedSection(
                    title: "Featured Collection",
                    products: viewModel.featuredProducts
                )
                
                // Gold divider
                goldDivider
                
                // MARK: - Recommendations
                RecommendationSection(products: viewModel.recommendations)
                
                // MARK: - Loyalty Banner
                loyaltyBanner
                
                // MARK: - Appointment Teaser
                appointmentTeaser
                
                // Bottom spacing for tab bar
                Color.clear.frame(height: 20)
            }
            .padding(.top, 8)
        }
        .background(AppColors.background)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("LUXE")
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.gold, AppColors.goldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Luxury Redefined")
                    .font(.caption)
                    .tracking(3)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            Spacer()
            
            // Notification bell
            Button(action: {}) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.pureWhite)
                    
                    // Notification dot
                    Circle()
                        .fill(AppColors.gold)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Gold Divider
    
    private var goldDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, AppColors.gold.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
            
            Image(systemName: "diamond.fill")
                .font(.system(size: 6))
                .foregroundStyle(AppColors.gold.opacity(0.5))
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.gold.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Loyalty Banner
    
    private var loyaltyBanner: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.surfaceGold)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                )
            
            // Decorative elements
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColors.gold.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: 120, y: -30)
            
            // Content
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.gold)
                        
                        Text("LUXE REWARDS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(2)
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text("Earn Points with\nEvery Purchase")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureWhite)
                        .lineSpacing(4)
                    
                    GoldButton(title: "JOIN NOW", isCompact: true)
                }
                
                Spacer()
                
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(AppColors.gold.opacity(0.2))
            }
            .padding(20)
        }
        .frame(height: 170)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Appointment Teaser
    
    private var appointmentTeaser: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
                )
            
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceGold)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .stroke(AppColors.gold.opacity(0.4), lineWidth: 1)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.gold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Book a Store Visit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureWhite)
                    
                    Text("Experience luxury in person. Book a private appointment.")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.gold)
            }
            .padding(16)
        }
        .frame(height: 88)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
