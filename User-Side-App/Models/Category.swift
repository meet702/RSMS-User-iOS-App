//
//  Category.swift
//  User-Side-App
//
//  Category data model for LUXE — supports remote background images
//

import Foundation

struct Category: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let imageURL: String? // Added for background images in Category Cards
    let productCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        imageURL: String? = nil,
        productCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.imageURL = imageURL
        self.productCount = productCount
    }
}
