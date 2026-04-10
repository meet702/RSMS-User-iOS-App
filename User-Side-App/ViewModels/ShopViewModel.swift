//
//  ShopViewModel.swift
//  User-Side-App
//
//  Business logic for the Shop tab — filtering, sorting, search
//

import SwiftUI

@Observable
class ShopViewModel {
    var searchText: String = ""
    var selectedCategory: String? = nil
    var selectedBrands: Set<String> = []
    var maxBudget: Double = 2_000_000
    var sortOption: SortOption = .popular
    
    enum SortOption: String, CaseIterable {
        case popular = "Popular"
        case newest = "Newest"
        case priceLowHigh = "Price: Low → High"
        case priceHighLow = "Price: High → Low"
    }
    
    var allProducts: [Product] { MockData.products }
    
    var filteredProducts: [Product] {
        var products = allProducts
        
        // Category filter
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        // Brand filter
        if !selectedBrands.isEmpty {
            products = products.filter { selectedBrands.contains($0.brand) }
        }
        
        // Budget filter
        products = products.filter { $0.price <= maxBudget }
        
        // Search filter
        if !searchText.isEmpty {
            products = products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortOption {
        case .popular:
            products.sort { $0.rating > $1.rating }
        case .newest:
            products.sort { ($0.isNew ? 0 : 1) < ($1.isNew ? 0 : 1) }
        case .priceLowHigh:
            products.sort { $0.price < $1.price }
        case .priceHighLow:
            products.sort { $0.price > $1.price }
        }
        
        return products
    }
    
    var availableBrands: [String] {
        Array(Set(allProducts.map(\.brand))).sorted()
    }
    
    var categoryNames: [String] {
        MockData.categories.map(\.name)
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !selectedBrands.isEmpty { count += 1 }
        if maxBudget < 2_000_000 { count += 1 }
        return count
    }
    
    func resetFilters() {
        selectedCategory = nil
        selectedBrands = []
        maxBudget = 2_000_000
        searchText = ""
        sortOption = .popular
    }
}
