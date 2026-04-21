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
    @State private var selectedCategory: Category? = nil
    @State private var showAllProducts = false
    
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
        .sheet(item: $selectedCategory) { category in
            SeeAllProductsView(
                title: category.name,
                products: products.filter { 
                    $0.category.localizedCaseInsensitiveContains(category.name) ||
                    category.name.localizedCaseInsensitiveContains($0.category)
                }
            )
        }
        .sheet(isPresented: $showAllProducts) {
            SeeAllProductsView(
                title: "All Categories",
                products: products
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
