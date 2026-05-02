//
//  CartManager.swift
//  User-Side-App
//
//  App-wide cart state manager for LUXE
//

import SwiftUI

@Observable
class CartManager {
    var items: [CartItem] = []
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    // MARK: - Remote Sync
    
    func loadCart(userId: UUID) async {
        do {
            let dtos = try await SyncManager.shared.fetchCart(userId: userId)
            self.items = dtos.compactMap { dto in
                guard let productDto = dto.products else { return nil }
                return CartItem(
                    product: productDto.toProduct(),
                    variant: dto.variant,
                    quantity: dto.quantity
                )
            }
        } catch {
            print("Failed to load cart: \(error)")
        }
    }
    
    // MARK: - Actions
    
    func addToCart(product: Product, variant: String? = nil, quantity: Int = 1, userId: UUID? = nil) {
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.variant == variant }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, variant: variant, quantity: quantity))
        }
        
        // Sync to remote if user is logged in
        if let userId = userId {
            Task {
                do {
                    let totalQuantity = items.first(where: { $0.product.id == product.id && $0.variant == variant })?.quantity ?? quantity
                    try await SyncManager.shared.syncAddToCart(
                        userId: userId,
                        productId: product.id,
                        variant: variant,
                        quantity: totalQuantity
                    )
                    print("✅ Cart Sync: Added/Updated \(product.name) (Total Qty: \(totalQuantity))")
                } catch {
                    print("❌ Cart Sync Error: Failed to add \(product.name) - \(error)")
                }
            }
        }
    }
    
    func removeFromCart(item: CartItem, userId: UUID? = nil) {
        items.removeAll { $0.id == item.id }
        
        // Sync to remote
        if let userId = userId {
            Task {
                do {
                    try await SyncManager.shared.syncRemoveFromCart(
                        userId: userId,
                        productId: item.product.id,
                        variant: item.variant
                    )
                    print("✅ Cart Sync: Removed \(item.product.name)")
                } catch {
                    print("❌ Cart Sync Error: Failed to remove \(item.product.name) - \(error)")
                }
            }
        }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int, userId: UUID? = nil) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                removeFromCart(item: item, userId: userId)
            } else {
                items[index].quantity = quantity
                
                // Sync to remote
                if let userId = userId {
                    Task {
                        do {
                            try await SyncManager.shared.syncAddToCart(
                                userId: userId,
                                productId: item.product.id,
                                variant: item.variant,
                                quantity: quantity
                            )
                            print("✅ Cart Sync: Updated quantity for \(item.product.name) to \(quantity)")
                        } catch {
                            print("❌ Cart Sync Error: Failed to update quantity for \(item.product.name) - \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func isInCart(product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }
    
    func clearCart(userId: UUID? = nil) {
        withAnimation {
            items.removeAll()
        }
        
        // Sync to remote
        if let userId = userId {
            Task {
                try? await SyncManager.shared.syncClearCart(userId: userId)
            }
        }
    }
}
