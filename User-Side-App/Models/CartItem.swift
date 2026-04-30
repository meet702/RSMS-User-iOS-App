//  CartItem.swift
//  User-Side-App
//  Cart item model for LUXE

import Foundation

struct CartItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let product: Product
    let variant: String?
    var quantity: Int

    init(id: UUID = UUID(), product: Product, variant: String? = nil, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.variant = variant
        self.quantity = quantity
    }

    var totalPrice: Double {
        product.price * Double(quantity)
    }
}
