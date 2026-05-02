//
//  CategorySection.swift
//  User-Side-App
//
//  Horizontal category browsing — iOS-standard scroll with subtle peek hint
//

import SwiftUI

struct CategorySection: View {
    let categories: [Category]
    let products: [Product]
    @Environment(NavigationManager.self) private var navManager
    @State private var showAllProducts = false
    @State private var selectedCategory: Category? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Shop by Category") {
                showAllProducts = true
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4) // breathing room for shadow/scale
            }
        }
        .sheet(isPresented: $showAllProducts) {
            SeeAllProductsView(
                title: "All Categories",
                products: products
            )
        }
        .sheet(item: $selectedCategory) { category in
            SeeAllProductsView(
                title: category.name,
                products: products.filter { $0.category == category.name }
            )
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        CategorySection(categories: MockData.categories, products: MockData.products)
    }
    .withLuxePreviewEnvironment()
}
