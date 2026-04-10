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
    
    func addToCart(product: Product, variant: String? = nil) {
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.variant == variant }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, variant: variant))
        }
    }
    
    func removeFromCart(item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    func isInCart(product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }
}
