//
//  RecommendationSection.swift
//  User-Side-App
//
//  AI-curated recommendations grid for LUXE Home tab
//

import SwiftUI

struct RecommendationSection: View {
    let products: [Product]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Curated for You ✨")
            
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(products) { product in
                    ProductCardGrid(product: product)
                }
            }
            .padding(.horizontal, 20)
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
}
