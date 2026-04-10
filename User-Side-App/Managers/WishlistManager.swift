//
//  WishlistManager.swift
//  User-Side-App
//
//  App-wide wishlist state manager for LUXE
//

import SwiftUI

@Observable
class WishlistManager {
    var productIDs: Set<UUID> = []
    
    func isWishlisted(_ product: Product) -> Bool {
        productIDs.contains(product.id)
    }
    
    func toggle(_ product: Product) {
        if productIDs.contains(product.id) {
            productIDs.remove(product.id)
        } else {
            productIDs.insert(product.id)
        }
    }
    
    var count: Int {
        productIDs.count
    }
    
    var wishlistedProducts: [Product] {
        MockData.products.filter { productIDs.contains($0.id) }
    }
}
