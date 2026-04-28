//
//  HomeView.swift
//  User-Side-App
//
//  LUXE Home Tab — Main scrollable view
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(NavigationManager.self) private var navManager
    @Environment(UserManager.self) private var userManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(ThemeManager.self) private var themeManager
    @State private var showProfile = false
    @State private var showOffersSheet = false
    @State private var activeOffers: [OfferDTO] = []
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Search Bar
                    HomeSearchBar(
                        searchText: $viewModel.searchText,
                        products: viewModel.allProducts
                    )
                    
                    // MARK: - Banner Carousel
                    BannerCarousel(
                        banners: viewModel.banners,
                        products: viewModel.allProducts
                    )
                    
                    // MARK: - Categories
                    CategorySection(
                        categories: viewModel.categories,
                        products: viewModel.allProducts
                    )
                    
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
                    
                    // MARK: - Offers Banner
                    offersBanner
                    
                    // MARK: - Appointment Teaser
                    appointmentTeaser
                    
                    // Bottom spacing for tab bar
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 8)
            }
            .refreshable {
                await viewModel.loadData()
            }
            .background(AppColors.background)
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showOffersSheet) {
                NavigationStack {
                    ZStack {
                        AppColors.background.ignoresSafeArea()
                        ScrollView {
                            if activeOffers.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "tag.slash")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppColors.grayLight)
                                    Text("No Active Offers")
                                        .font(.headline)
                                        .foregroundStyle(AppColors.pureWhite)
                                }
                                .padding(.top, 100)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(activeOffers) { offer in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(offer.name).font(.subheadline).fontWeight(.bold).foregroundStyle(AppColors.gold)
                                                if let code = offer.coupon_code {
                                                    Text("Code: \(code)").font(.caption).foregroundStyle(AppColors.grayLight)
                                                }
                                            }
                                            Spacer()
                                            let discountValue = offer.discount_value ?? 0.0
                                            let type = (offer.discount_type ?? "fixed").lowercased()
                                            
                                            if type == "percentage" {
                                                Text("\(Int(discountValue))% OFF").font(.caption).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                                            } else {
                                                Text("₹\(Int(discountValue)) OFF").font(.caption).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                                            }
                                        }
                                        .padding()
                                        .background(AppColors.surfaceDark)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .navigationTitle("Active Offers")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showOffersSheet = false }
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("DIOR")
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
            Button(action: { navManager.showNotifications = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.pureWhite)
                    
                    // Notification dot
                    if notificationManager.hasUnreadNotifications {
                        Circle()
                            .fill(AppColors.gold)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .padding(.trailing, 8)
            
            // Profile Icon
            Button(action: { showProfile = true }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.goldSubtle)
                        .frame(width: 32, height: 32)
                    
                    Text(userManager.currentUser?.initials ?? "??")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.alwaysBlack)
                }
                .overlay(Circle().stroke(AppColors.gold.opacity(0.3), lineWidth: 1.5))
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
    
    // MARK: - Offers Banner
    
    private var offersBanner: some View {
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
                        Image(systemName: "tag.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.gold)
                        
                        Text("ACTIVE OFFERS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(2)
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text("Unlock exclusive\ndiscounts at checkout")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureWhite)
                        .lineSpacing(4)
                    
                    GoldButton(title: "SHOW OFFERS", isCompact: true) {
                        Task {
                            if let offers = try? await SyncManager.shared.fetchActiveOffers() {
                                await MainActor.run { activeOffers = offers }
                            }
                        }
                        showOffersSheet = true
                    }
                }
                
                Spacer()
                
                Image(systemName: "percent")
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
        Button(action: { navManager.showAppointments = true }) {
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
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.gold)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 88)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView()
        .withLuxePreviewEnvironment()
}
