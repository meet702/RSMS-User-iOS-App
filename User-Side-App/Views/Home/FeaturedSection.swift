//
//  FeaturedSection.swift
//  User-Side-App
//
//  Featured / New Arrivals horizontal scroll for LUXE Home tab
//  Shows 2 visible cards with horizontal scroll + "See All" sheet
//

import SwiftUI

struct FeaturedSection: View {
    let title: String
    let products: [Product]
    @State private var showAll = false
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: title) {
                showAll = true
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(products.prefix(4)) { product in
                        NavigationLink(value: product) {
                            ProductCardHorizontal(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAll) {
            SeeAllProductsView(title: title, products: products)
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
    .withLuxePreviewEnvironment()
}
