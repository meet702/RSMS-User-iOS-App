//
//  WishlistView.swift
//  User-Side-App
//
//  LUXE Wishlist — saved products grid
//

import SwiftUI

struct WishlistView: View {
    @Environment(WishlistManager.self) private var wishlistManager
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if wishlistManager.items.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Count
                    HStack {
                        Text("\(wishlistManager.count) saved items")
                            .font(.caption)
                            .foregroundStyle(AppColors.grayLight)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Product grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(wishlistManager.items) { product in
                            NavigationLink(value: product) {
                                ProductCardGrid(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 8)
            }
        }
        .background(AppColors.background)
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("WISHLIST")
                    .font(.headline)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(AppColors.gold)
            }
        }
        }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 80)
            
            ZStack {
                Circle()
                    .fill(AppColors.surfaceDark)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
            }
            
            VStack(spacing: 8) {
                Text("Your Wishlist is Empty")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text("Save items you love for later.\nTap the ♡ on any product to add it here.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Rectangle()
                .fill(AppColors.gold.opacity(0.3))
                .frame(width: 40, height: 1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        WishlistView()
    }
    .withLuxePreviewEnvironment()
}
