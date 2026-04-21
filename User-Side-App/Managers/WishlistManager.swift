//
//  WishlistManager.swift
//  User-Side-App
//
//  App-wide wishlist state manager for LUXE
//

import SwiftUI

@Observable
class WishlistManager {
    var items: [Product] = []
    
    var count: Int {
        items.count
    }
    
    // MARK: - Remote Sync
    
    func loadWishlist(userId: UUID) async {
        do {
            self.items = try await SyncManager.shared.fetchWishlist(userId: userId)
        } catch {
            print("Failed to load wishlist: \(error)")
        }
    }
    
    // MARK: - Actions
    
    func isWishlisted(_ product: Product) -> Bool {
        items.contains { $0.id == product.id }
    }
    
    func toggle(_ product: Product, userId: UUID? = nil) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items.remove(at: index)
            
            // Sync remove
            if let userId = userId {
                Task {
                    try? await SyncManager.shared.syncRemoveFromWishlist(userId: userId, productId: product.id)
                }
            }
        } else {
            items.append(product)
            
            // Sync add
            if let userId = userId {
                Task {
                    try? await SyncManager.shared.syncAddToWishlist(userId: userId, productId: product.id)
                }
            }
        }
    }
}
