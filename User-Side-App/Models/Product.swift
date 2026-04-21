//
//  Product.swift
//  User-Side-App
//
//  Product data model for LUXE — with remote image URL support
//

import Foundation

struct Product: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let brand: String
    var price: Double
    let originalPrice: Double?
    let imageName: String      // local Asset name (may not exist → falls back to imageURL)
    let imageURL: String?      // remote URL for web-scraped product images
    let category: String
    let isNew: Bool
    let rating: Double
    let isFeatured: Bool
    let description: String
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        price: Double,
        originalPrice: Double? = nil,
        imageName: String = "",
        imageURL: String? = nil,
        category: String,
        isNew: Bool = false,
        rating: Double = 4.5,
        isFeatured: Bool = false,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.price = price
        self.originalPrice = originalPrice
        self.imageName = imageName
        self.imageURL = imageURL
        self.category = category
        self.isNew = isNew
        self.rating = rating
        self.isFeatured = isFeatured
        self.description = description
    }
    
    var hasDiscount: Bool {
        originalPrice != nil && originalPrice! > price
    }
    
    var discountPercentage: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int(((original - price) / original) * 100)
    }
}
