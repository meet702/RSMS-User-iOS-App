//
//  FeaturedSection.swift
//  User-Side-App
//
//  Featured / New Arrivals horizontal scroll for LUXE Home tab
//

import SwiftUI

struct FeaturedSection: View {
    let title: String
    let products: [Product]
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(products) { product in
                        ProductCardHorizontal(product: product)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        FeaturedSection(
            title: "New Arrivals",
            products: MockData.newArrivals
        )
    }
}
