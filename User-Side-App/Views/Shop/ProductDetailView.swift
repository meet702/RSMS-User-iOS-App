//  ProductDetailView.swift
//  User-Side-App
//  LUXE Product detail page  images, info, variants, authenticity, buy

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @Environment(CartManager.self) private var cartManager
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVariant: String? = nil
    @State private var currentImageIndex: Int = 0
    @State private var showAddedToCart: Bool = false
    @State private var isDescriptionExpanded: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var reviews: [ReviewDTO] = []
    @State private var quantity: Int = 1

    private var dynamicRating: Double {
        if reviews.isEmpty { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }

    private var dynamicReviewCount: Int {
        reviews.count
    }

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

                        // Quantity
                        quantitySelector

                        // Divider
                        thinDivider

                        // Description
                        descriptionSection

                        // Delivery info
                        deliveryInfo

                        // Divider
                        thinDivider

                        // Reviews
                        ProductReviewsView(productId: product.id, reviews: $reviews)

                        // Bottom spacing for action buttons
                        Color.clear.frame(height: product.category == "Watches" || product.category == "Fashion" ? 160 : 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }

            // Bottom action buttons
            bottomButtons

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
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { wishlistManager.toggle(product, userId: userManager.supabaseUserId) }) {
                        Image(systemName: wishlistManager.isWishlisted(product) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.gold)
                            .padding(8)
                            .background(AppColors.background.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(wishlistManager.isWishlisted(product) ? "Remove from wishlist" : "Add to wishlist")

                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.pureWhite)
                            .padding(8)
                            .background(AppColors.background.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Share product")
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if selectedVariant == nil, let first = variants.first {
                selectedVariant = first
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "Check out \(product.name) by \(product.brand) on DIOR! \(product.price.formattedPrice)",
                URL(string: "https://dior.com")!
            ])
            .presentationDetents([.medium])
        }
    }

    // MARK: - Image Gallery

    private var imageGallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentImageIndex) {
                ForEach(0..<3, id: \.self) { index in
                    ZStack {
                        AsyncProductImage(product: product, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .clipped()

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.35)],
                            startPoint: .top, endPoint: .bottom
                        )
                    }
                    .tag(index)
                    .accessibilityLabel("Product image \(index + 1) of 3")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index == currentImageIndex ? AppColors.gold : AppColors.grayDark)
                        .frame(width: index == currentImageIndex ? 20 : 6, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentImageIndex)
                }
            }
            .padding(.bottom, 16)
            .accessibilityHidden(true)
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

            Text(LocalizedStringKey(product.name))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.pureWhite)

            // Rating
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(dynamicRating) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.gold)
                    }
                }

                Text("\(String(format: "%.1f", dynamicRating))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)

                Text("(\(dynamicReviewCount) reviews)")
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rating: \(String(format: "%.1f", dynamicRating)) out of 5 stars, based on \(dynamicReviewCount) reviews")
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
                        .accessibilityLabel(variant)
                        .accessibilityHint(selectedVariant == variant ? "Currently selected" : "Double tap to select \(variant)")
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

            Text(LocalizedStringKey(product.description))
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

    // MARK: - Quantity Selector

    private var quantitySelector: some View {
        HStack {
            Text("Quantity")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)

            Spacer()

            HStack(spacing: 20) {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.pureWhite)
                        .frame(width: 32, height: 32)
                        .background(AppColors.surfaceDark)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Decrease quantity")

                Text("\(quantity)")
                    .font(.headline)
                    .foregroundStyle(AppColors.pureWhite)
                    .frame(minWidth: 30)
                    .accessibilityLabel("Quantity: \(quantity)")

                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .frame(width: 32, height: 32)
                        .background(AppColors.gold)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Increase quantity")
            }
            .padding(4)
            .background(AppColors.surfaceDark)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
            )
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
        VStack(spacing: 12) {

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
                Button(action: { buyNow() }) {
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            AppColors.surfaceDark
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
        .fullScreenCover(item: $directPurchaseItem) { item in
            CheckoutView(directPurchaseItem: item)
        }
        .task {
            try? await loadReviews()
        }
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Added to Cart")
            .onAppear {
                AccessibilityNotification.Announcement("Added to Cart").post()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    @State private var directPurchaseItem: CartItem? = nil

    private func addToCart() {
        cartManager.addToCart(product: product, variant: selectedVariant, quantity: quantity, userId: userManager.supabaseUserId)
        withAnimation(.spring(response: 0.4)) {
            showAddedToCart = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { showAddedToCart = false }
        }
    }

    private func buyNow() {
        let item = CartItem(
            product: product,
            variant: selectedVariant,
            quantity: quantity
        )
        directPurchaseItem = item
    }

    private func loadReviews() async throws {
        self.reviews = try await SyncManager.shared.fetchReviews(productId: product.id)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: MockData.products[0])
    }
    .withLuxePreviewEnvironment()
}
