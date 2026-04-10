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
    var currentBannerIndex: Int = 0
    
    let categories: [Category] = MockData.categories
    let featuredProducts: [Product] = MockData.featuredProducts
    let newArrivals: [Product] = MockData.newArrivals
    let banners: [PromoBanner] = MockData.banners
    
    // Recommendations (in real app, this would be AI-driven)
    var recommendations: [Product] {
        MockData.products
    }
}
