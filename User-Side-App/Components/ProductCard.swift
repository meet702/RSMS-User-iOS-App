//
//  ProductCard.swift
//  User-Side-App
//
//  Reusable product cards — uses AsyncProductImage for web image loading
//

import SwiftUI

// MARK: - Horizontal Product Card (Featured / New Arrivals)

struct ProductCardHorizontal: View {
    let product: Product
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(CartManager.self) private var cartManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncProductImage(product: product)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()
                
                Button(action: { wishlistManager.toggle(product, userId: userManager.supabaseUserId) }) {
                    Image(systemName: wishlistManager.isWishlisted(product) ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.gold)
                        .padding(8)
                        .background(.ultraThinMaterial.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(10)
                
                if product.isNew {
                    VStack {
                        Spacer()
                        HStack {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold)).tracking(2)
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(AppColors.gold).clipShape(Capsule())
                                .padding(10)
                            Spacer()
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand)
                    .font(.system(size: 10, weight: .semibold)).tracking(2)
                    .foregroundStyle(AppColors.gold)
                Text(LocalizedStringKey(product.name))
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite).lineLimit(1)
                HStack(spacing: 6) {
                    Text(product.price.formattedPrice)
                        .font(.subheadline).fontWeight(.bold).foregroundStyle(AppColors.gold)
                    if let original = product.originalPrice {
                        Text(original.formattedPrice)
                            .font(.caption2).foregroundStyle(AppColors.grayLight)
                            .strikethrough(color: AppColors.grayLight)
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
        }
        .frame(width: 180)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Grid Product Card (Shop / Recommendations)

struct ProductCardGrid: View {
    let product: Product
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncProductImage(product: product)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .clipped()
                
                Button(action: { wishlistManager.toggle(product, userId: userManager.supabaseUserId) }) {
                    Image(systemName: wishlistManager.isWishlisted(product) ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.gold)
                        .padding(6)
                        .background(.ultraThinMaterial.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.system(size: 9, weight: .semibold)).tracking(1.5)
                    .foregroundStyle(AppColors.gold)
                Text(LocalizedStringKey(product.name))
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite).lineLimit(1)
                HStack(spacing: 4) {
                    Text(product.price.formattedPrice)
                        .font(.caption).fontWeight(.bold).foregroundStyle(AppColors.goldLight)
                    if let pct = product.discountPercentage {
                        Text("\(pct)% OFF")
                            .font(.system(size: 9, weight: .bold)).foregroundStyle(AppColors.goldDark)
                    }
                }
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                            .font(.system(size: 8)).foregroundStyle(AppColors.gold.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
        }
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.gold.opacity(0.1), lineWidth: 1))
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 20) {
                ProductCardHorizontal(product: MockData.products[0])
                HStack {
                    ProductCardGrid(product: MockData.products[1])
                    ProductCardGrid(product: MockData.products[2])
                }
                .padding(.horizontal)
            }
        }
    }
    .environment(WishlistManager())
}
