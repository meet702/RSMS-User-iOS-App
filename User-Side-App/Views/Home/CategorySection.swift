//
//  CategorySection.swift
//  User-Side-App
//
//  Horizontal category browsing section for LUXE Home tab
//

import SwiftUI

struct CategorySection: View {
    let categories: [Category]
    @Environment(NavigationManager.self) private var navManager
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Shop by Category")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category) {
                            navManager.navigateToShop(withCategory: category.name)
                        }
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
        CategorySection(categories: MockData.categories)
    }
}
