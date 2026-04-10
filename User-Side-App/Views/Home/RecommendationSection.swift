//
//  RecommendationSection.swift
//  User-Side-App
//
//  AI-curated recommendations for LUXE Home tab
//  Shows 2 visible cards with horizontal scroll + "See All" sheet
//

import SwiftUI

struct RecommendationSection: View {
    let products: [Product]
    @State private var showAll = false
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Curated for You ✨") {
                showAll = true
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(products.prefix(4)) { product in
                        ProductCardHorizontal(product: product)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAll) {
            SeeAllProductsView(title: "Curated for You", products: products)
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            RecommendationSection(products: MockData.products)
        }
    }
    .environment(WishlistManager())
}
