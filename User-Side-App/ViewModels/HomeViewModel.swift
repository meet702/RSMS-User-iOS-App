//
//  HomeViewModel.swift
//  User-Side-App
//
//  Business logic for the Home tab
//

import SwiftUI

@Observable
class HomeViewModel {
    var searchText: String = ""
    var isLoading: Bool = false
    
    var categories: [Category] = []
    var allProducts: [Product] = [] // All products from remote
    
    // Dynamic lists derived from remote product state
    var featuredProducts: [Product] {
        allProducts.filter { $0.price > 100_000 }.prefix(6).map { $0 }
    }
    
    var newArrivals: [Product] {
        allProducts.prefix(8).map { $0 }
    }
    
    var recommendations: [Product] {
        allProducts.shuffled().prefix(4).map { $0 }
    }
    
    let banners: [PromoBanner] = MockData.banners // Keep static for now
    
    init() {
        Task { await loadData() }
    }
    
    func loadData() async {
        isLoading = true
        do {
            async let productsTask = SyncManager.shared.fetchProducts()
            async let categoriesTask = SyncManager.shared.fetchCategories()
            
            let (products, rawCategories) = try await (productsTask, categoriesTask)
            self.allProducts = products
            
            // Only show categories that actually have products in the synced list
            self.categories = rawCategories.filter { cat in
                products.contains { p in
                    p.category.localizedCaseInsensitiveContains(cat.name) ||
                    cat.name.localizedCaseInsensitiveContains(p.category)
                }
            }
        } catch {
            print("Failed to sync home data: \(error)")
        }
        isLoading = false
    }
}
