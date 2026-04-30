//
//  Order.swift
//  User-Side-App
//
//  Order data models for LUXE
//

import Foundation

enum OrderStatus: String, CaseIterable, Codable, Sendable {
    case placed = "placed"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var isActive: Bool {
        return self == .placed || self == .shipped
    }
    
    /// Fuzzy initializer to handle database variations
    static func from(string: String) -> OrderStatus {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespaces)
        
        switch normalized {
        case "shipped", "dispatched", "on_the_way":
            return .shipped
        case "delivered", "completed", "received":
            return .delivered
        case "cancelled", "canceled", "rejected":
            return .cancelled
        default:
            return .placed
        }
    }
}

struct TrackingStep: Identifiable, Hashable, Sendable {
    let id = UUID()
    let status: OrderStatus
    let date: Date?
    let title: String
    let description: String
    let isCompleted: Bool
}

struct OrderItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let product: Product
    let variant: String?
    let quantity: Int
    let priceAtPurchase: Double
    
    init(id: UUID = UUID(), product: Product, variant: String? = nil, quantity: Int, priceAtPurchase: Double) {
        self.id = id
        self.product = product
        self.variant = variant
        self.quantity = quantity
        self.priceAtPurchase = priceAtPurchase
    }
}

struct Order: Identifiable, Hashable, Sendable {
    let id: UUID
    let orderNumber: String
    let date: Date
    let items: [OrderItem]
    let subtotal: Double
    let taxes: Double
    let deliveryFee: Double
    let discount: Double
    let offer_id: UUID?
    var finalTotal: Double {
        max(1.0, subtotal + taxes + deliveryFee - discount)
    }
    
    var status: OrderStatus
    var trackingSteps: [TrackingStep]
    var estimatedDelivery: Date?
    
    init(
        id: UUID = UUID(),
        orderNumber: String,
        date: Date,
        items: [OrderItem],
        subtotal: Double,
        taxes: Double,
        deliveryFee: Double = 0,
        discount: Double = 0,
        status: OrderStatus,
        trackingSteps: [TrackingStep] = [],
        estimatedDelivery: Date? = nil,
        offer_id: UUID? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.date = date
        self.items = items
        self.subtotal = subtotal
        self.taxes = taxes
        self.deliveryFee = deliveryFee
        self.discount = discount
        self.status = status
        self.trackingSteps = trackingSteps
        self.estimatedDelivery = estimatedDelivery
        self.offer_id = offer_id
    }
}
