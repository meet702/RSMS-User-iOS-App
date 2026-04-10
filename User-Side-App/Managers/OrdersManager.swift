//
//  OrdersManager.swift
//  User-Side-App
//
//  Global Environment manager handling active and past orders for LUXE
//

import SwiftUI

@Observable
class OrdersManager {
    var orders: [Order]
    var selectedTab: OrderTab = .active
    
    enum OrderTab: String, CaseIterable {
        case active = "Active Orders"
        case past = "Past Orders"
    }
    
    init(orders: [Order] = MockData.orders) {
        self.orders = orders
    }
    
    var activeOrders: [Order] {
        orders.filter { $0.status.isActive }
            .sorted { $0.date > $1.date }
    }
    
    var pastOrders: [Order] {
        orders.filter { !$0.status.isActive }
            .sorted { $0.date > $1.date }
    }
    
    var currentOrders: [Order] {
        selectedTab == .active ? activeOrders : pastOrders
    }
    
    // MARK: - Actions
    
    func cancelOrder(_ orderID: UUID) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            var updatedOrder = orders[index]
            updatedOrder.status = .cancelled
            
            // Mark remaining steps as incomplete and add cancelled step
            let cancelledStep = TrackingStep(
                status: .cancelled,
                date: Date(),
                title: "Order Cancelled",
                description: "You cancelled this order.",
                isCompleted: true
            )
            
            var newSteps = updatedOrder.trackingSteps.map { step -> TrackingStep in
                TrackingStep(
                    status: step.status,
                    date: step.date,
                    title: step.title,
                    description: step.description,
                    isCompleted: step.status == .placed ? true : false
                )
            }
            newSteps.append(cancelledStep)
            updatedOrder.trackingSteps = newSteps
            
            orders[index] = updatedOrder
            
            // Auto switch to past orders if no active orders left
            if activeOrders.isEmpty {
                selectedTab = .past
            }
        }
    }
    
    func addOrder(_ newOrder: Order) {
        orders.insert(newOrder, at: 0)
        selectedTab = .active
    }
}
