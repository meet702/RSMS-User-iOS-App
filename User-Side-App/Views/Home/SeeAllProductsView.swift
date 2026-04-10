//
//  SeeAllProductsView.swift
//  User-Side-App
//
//  Full product list sheet — opened from "See All" in Home sections
//

import SwiftUI

struct SeeAllProductsView: View {
    let title: String
    let products: [Product]
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Product count
                    HStack {
                        Text("\(products.count) items")
                            .font(.caption)
                            .foregroundStyle(AppColors.grayLight)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Product grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(products) { product in
                            ProductCardGrid(product: product)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 8)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title.uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.grayLight)
                            .padding(8)
                            .background(AppColors.surfaceElevated)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

#Preview {
    SeeAllProductsView(title: "New Arrivals", products: MockData.newArrivals)
        .environment(WishlistManager())
}
