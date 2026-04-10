//
//  ProductDetailView.swift
//  User-Side-App
//
//  LUXE Product detail page — images, info, variants, authenticity, buy
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    @Environment(CartManager.self) private var cartManager
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVariant: String? = nil
    @State private var currentImageIndex: Int = 0
    @State private var showAddedToCart: Bool = false
    @State private var isDescriptionExpanded: Bool = false
    
    private var variants: [String] {
        MockData.variants(for: product)
    }
    
    private let imageGradients: [(Color, Color)] = [
        (AppColors.surfaceGold, AppColors.surfaceDark),
        (AppColors.surfaceDark, AppColors.surfaceGold),
        (Color(hex: "0D0D08"), AppColors.surfaceDark),
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Image Gallery
                    imageGallery
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Brand & Name
                        productInfo
                        
                        // Price
                        priceSection
                        
                        // Divider
                        thinDivider
                        
                        // Variant selector
                        variantSelector
                        
                        // Divider
                        thinDivider
                        
                        // Description
                        descriptionSection
                        
                        // Authenticity certificate
                        AuthenticityView()
                            .padding(.horizontal, -20)
                        
                        // Delivery info
                        deliveryInfo
                        
                        // Bottom spacing for action buttons
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            
            // Bottom action buttons
            bottomButtons
            
            // Added to cart toast
            if showAddedToCart {
                addedToCartToast
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(AppColors.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.pureWhite)
                        .padding(8)
                        .background(AppColors.background.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { wishlistManager.toggle(product) }) {
                        Image(systemName: wishlistManager.isWishlisted(product) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.gold)
                            .padding(8)
                            .background(AppColors.background.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.pureWhite)
                            .padding(8)
                            .background(AppColors.background.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if selectedVariant == nil, let first = variants.first {
                selectedVariant = first
            }
        }
    }
    
    // MARK: - Image Gallery
    
    private var imageGallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentImageIndex) {
                ForEach(0..<3, id: \.self) { index in
                    ZStack {
                        LinearGradient(
                            colors: [imageGradients[index].0, imageGradients[index].1],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Decorative glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppColors.gold.opacity(0.08), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                        
                        Image(systemName: product.imageName)
                            .font(.system(size: 80, weight: .ultraLight))
                            .foregroundStyle(AppColors.gold.opacity(0.45))
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
            
            // Custom page indicators
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index == currentImageIndex ? AppColors.gold : AppColors.grayDark)
                        .frame(
                            width: index == currentImageIndex ? 20 : 6,
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentImageIndex)
                }
            }
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Product Info
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.brand)
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(3)
                .foregroundStyle(AppColors.gold)
            
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.pureWhite)
            
            // Rating
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.gold)
                    }
                }
                
                Text("\(String(format: "%.1f", product.rating))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text("(42 reviews)")
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
            }
        }
    }
    
    // MARK: - Price
    
    private var priceSection: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Text(product.price.formattedPrice)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.gold)
            
            if let original = product.originalPrice {
                Text(original.formattedPrice)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .strikethrough(color: AppColors.grayLight)
            }
            
            if let pct = product.discountPercentage {
                Text("\(pct)% OFF")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.background)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.gold)
                    .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Variant Selector
    
    private var variantSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Size / Variant")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Spacer()
                
                if let variant = selectedVariant {
                    Text(variant)
                        .font(.caption)
                        .foregroundStyle(AppColors.gold)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(variants, id: \.self) { variant in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedVariant = variant
                            }
                        }) {
                            Text(variant)
                                .font(.subheadline)
                                .fontWeight(selectedVariant == variant ? .semibold : .regular)
                                .foregroundStyle(
                                    selectedVariant == variant
                                    ? AppColors.background : AppColors.pureWhite
                                )
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    selectedVariant == variant
                                    ? AppColors.gold : AppColors.surfaceDark
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            selectedVariant == variant
                                            ? .clear : AppColors.grayDark.opacity(0.5),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(PressButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(AppColors.grayLight)
                .lineSpacing(4)
                .lineLimit(isDescriptionExpanded ? nil : 3)
            
            if product.description.count > 100 {
                Button(action: {
                    withAnimation { isDescriptionExpanded.toggle() }
                }) {
                    Text(isDescriptionExpanded ? "Show Less" : "Read More")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
    
    // MARK: - Delivery Info
    
    private var deliveryInfo: some View {
        VStack(spacing: 12) {
            deliveryRow(icon: "truck.box", title: "Free Delivery", subtitle: "Estimated 3–5 business days")
            deliveryRow(icon: "arrow.triangle.2.circlepath", title: "Easy Returns", subtitle: "15-day return policy")
            deliveryRow(icon: "gift", title: "Premium Packaging", subtitle: "Luxury gift-ready packaging included")
        }
        .padding(16)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func deliveryRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.gold.opacity(0.7))
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Thin Divider
    
    private var thinDivider: some View {
        Rectangle()
            .fill(AppColors.grayDark.opacity(0.3))
            .frame(height: 0.5)
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        HStack(spacing: 12) {
            // Add to Cart
            Button(action: { addToCart() }) {
                HStack(spacing: 8) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 16))
                    Text("ADD TO CART")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .tracking(1)
                }
                .foregroundStyle(AppColors.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .overlay(
                    Capsule()
                        .stroke(AppColors.gold, lineWidth: 1.5)
                )
            }
            .buttonStyle(PressButtonStyle())
            
            // Buy Now
            Button(action: {}) {
                Text("BUY NOW")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient.goldSubtle)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            AppColors.surfaceDark
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Toast
    
    private var addedToCartToast: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                Text("Added to Cart")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(AppColors.background)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.gold)
            .clipShape(Capsule())
            .shadow(color: AppColors.gold.opacity(0.3), radius: 10)
            .padding(.top, 60)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    
    private func addToCart() {
        cartManager.addToCart(product: product, variant: selectedVariant)
        withAnimation(.spring(response: 0.4)) {
            showAddedToCart = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { showAddedToCart = false }
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: MockData.products[0])
    }
    .environment(CartManager())
    .environment(WishlistManager())
}
