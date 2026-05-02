//
//  AsyncProductImage.swift
//  User-Side-App
//
//  Shared async image loader for LUXE products.
//  IMPORTANT: Always call with an explicit frame (width + height) on the
//  outside — the view itself stretches to fill whatever frame is given.
//
//  Usage:
//    AsyncProductImage(product: product)
//        .frame(maxWidth: .infinity, height: 160)
//        .clipped()
//

import SwiftUI

struct AsyncProductImage: View {
    let product: Product
    var contentMode: ContentMode = .fill
    
    var body: some View {
        GeometryReader { geo in
            Group {
                // 1️⃣ Local asset exists
                if !product.imageName.isEmpty, UIImage(named: product.imageName) != nil {
                    Image(product.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .accessibilityLabel("Product image of \(product.name)")
                        .accessibilityAddTraits(.isImage)
                }
                // 2️⃣ Remote URL
                else if let urlString = product.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url, transaction: Transaction(animation: .easeIn(duration: 0.3))) { phase in
                        switch phase {
                        case .empty:
                            ShimmerPlaceholder(category: product.category)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .accessibilityLabel("Loading image for \(product.name)")
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .accessibilityLabel("Product image of \(product.name)")
                                .accessibilityAddTraits(.isImage)
                        case .failure:
                            CategoryFallbackIcon(category: product.category)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .accessibilityLabel("Product image of \(product.name) not available")
                        @unknown default:
                            ShimmerPlaceholder(category: product.category)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .accessibilityLabel("Loading image for \(product.name)")
                        }
                    }
                }
                // 3️⃣ Nothing at all
                else {
                    CategoryFallbackIcon(category: product.category)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .accessibilityLabel("Product image of \(product.name) not available")
                }
            }
        }
    }
}

// MARK: - Shimmer Placeholder

struct ShimmerPlaceholder: View {
    let category: String
    @State private var shimmer = false
    
    var body: some View {
        ZStack {
            AppColors.surfaceElevated
            
            // Shimmer sweep
            LinearGradient(
                colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.06),
                    Color.white.opacity(0.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: shimmer ? 400 : -400)
            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: shimmer)
            .onAppear { shimmer = true }
            
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(AppColors.gold.opacity(0.2))
        }
    }
    
    private func categoryIcon(for cat: String) -> String {
        switch cat {
        case "Watches":     return "applewatch"
        case "Jewelry":     return "sparkles"
        case "Fashion":     return "tshirt.fill"
        case "Handbags":    return "bag.fill"
        case "Shoes":       return "shoeprints.walk.fill"
        case "Fragrances":  return "drop.fill"
        case "Accessories", "Sunglasses": return "sunglasses"
        default:            return "shippingbox"
        }
    }
}

// MARK: - Category Fallback Icon

struct CategoryFallbackIcon: View {
    let category: String
    
    var body: some View {
        ZStack {
            AppColors.surfaceElevated
            Image(systemName: icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundStyle(AppColors.gold.opacity(0.35))
        }
    }
    
    private var icon: String {
        switch category {
        case "Watches":     return "applewatch"
        case "Jewelry":     return "sparkles"
        case "Fashion":     return "tshirt.fill"
        case "Handbags":    return "bag.fill"
        case "Shoes":       return "shoeprints.walk.fill"
        case "Fragrances":  return "drop.fill"
        case "Accessories", "Sunglasses": return "sunglasses"
        default:            return "shippingbox"
        }
    }
}
