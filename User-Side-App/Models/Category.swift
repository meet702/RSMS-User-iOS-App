//
//  Category.swift
//  User-Side-App
//
//  Category data model for LUXE
//

import Foundation

struct Category: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let productCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        productCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.productCount = productCount
    }
}
