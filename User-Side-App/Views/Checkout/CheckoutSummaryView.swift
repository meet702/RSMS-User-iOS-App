//
//  CheckoutSummaryView.swift
//  User-Side-App
//
//  Step 3 of Checkout: Final Review and Place Order
//

import SwiftUI

struct CheckoutSummaryView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(OrdersManager.self) private var ordersManager
    @Environment(ProfileManager.self) private var profileManager
    
    // Using NavigationPath or root un-winding would be better, but we can simulate success.
    @Environment(\.dismiss) private var dismiss
    
    let addressId: UUID
    let paymentMethod: String
    
    @State private var showSuccess = false
    
    var deliveryAddress: Address? {
        profileManager.addresses.first { $0.id == addressId }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    CheckoutStepper(currentStep: 3)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    Text("Review Your Order")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                        .padding(.horizontal, 20)
                    
                    // Selected Address
                    if let address = deliveryAddress {
                        reviewSection(title: "Delivery Address", icon: "house") {
                            Text(address.name)
                                .fontWeight(.bold)
                            Text("\(address.street)\n\(address.city), \(address.state) \(address.zipCode)")
                                .foregroundStyle(AppColors.grayLight)
                        }
                    }
                    
                    // Payment Method
                    reviewSection(title: "Payment Method", icon: "creditcard") {
                        Text(paymentMethod)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.grayLight)
                    }
                    
                    // Items list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items (\(cartManager.totalItems))")
                            .font(.headline)
                            .foregroundStyle(AppColors.pureWhite)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(cartManager.items) { item in
                                HStack {
                                    Text("\(item.quantity)x \(item.product.name)")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.pureWhite)
                                        .lineLimit(1)
                                    Spacer()
                                    Text((item.product.price * Double(item.quantity)).formattedPrice)
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.pureWhite)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .darkCard()
                    .padding(.horizontal, 20)
                    
                    // Final Totals
                    VStack(spacing: 12) {
                        HStack {
                            Text("Subtotal")
                                .foregroundStyle(AppColors.grayLight)
                            Spacer()
                            Text(cartManager.subtotal.formattedPrice)
                                .foregroundStyle(AppColors.pureWhite)
                        }
                        HStack {
                            Text("Taxes (18%)")
                                .foregroundStyle(AppColors.grayLight)
                            Spacer()
                            Text(cartManager.taxes.formattedPrice)
                                .foregroundStyle(AppColors.pureWhite)
                        }
                        HStack {
                            Text("Delivery Fee")
                                .foregroundStyle(AppColors.grayLight)
                            Spacer()
                            Text("FREE")
                                .foregroundStyle(AppColors.gold)
                        }
                        Divider()
                            .background(AppColors.grayDark.opacity(0.5))
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text("Final Total")
                                .font(.headline)
                                .foregroundStyle(AppColors.pureWhite)
                            Spacer()
                            Text((cartManager.subtotal + cartManager.taxes).formattedPrice)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    .font(.subheadline)
                    .padding(20)
                    .darkCard()
                    .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 100)
                }
            }
            
            // Bottom Bar
            VStack {
                Button(action: placeOrder) {
                    HStack {
                        Spacer()
                        if showSuccess {
                            ProgressView()
                                .tint(AppColors.background)
                        } else {
                            Text("PLACE ORDER")
                                .fontWeight(.bold)
                                .tracking(1)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .foregroundStyle(AppColors.background)
                    .padding(.vertical, 16)
                    .background(LinearGradient.goldSubtle)
                    .clipShape(Capsule())
                }
                .disabled(showSuccess)
                .buttonStyle(PressButtonStyle())
            }
            .padding(20)
            .background(AppColors.surfaceDark.ignoresSafeArea(edges: .bottom))
        }
        .background(AppColors.background)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func reviewSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColors.gold)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppColors.grayMedium)
                    .textCase(.uppercase)
                
                content()
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(20)
        .darkCard()
        .padding(.horizontal, 20)
    }
    
    private func placeOrder() {
        showSuccess = true
        
        let orderItems = cartManager.items.map { item in
            OrderItem(product: item.product, variant: item.variant, quantity: item.quantity, priceAtPurchase: item.product.price)
        }
        
        let newOrder = Order(
            orderNumber: "ORD-\(Int.random(in: 1000...9999))-\(Int.random(in: 100...999))",
            date: Date(),
            items: orderItems,
            subtotal: cartManager.subtotal,
            taxes: cartManager.taxes,
            deliveryFee: 0,
            status: .placed,
            trackingSteps: [
                TrackingStep(status: .placed, date: Date(), title: "Order Placed", description: "Your order has been received.", isCompleted: true),
                TrackingStep(status: .processing, date: nil, title: "Processing", description: "We are preparing your item for dispatch.", isCompleted: false),
                TrackingStep(status: .dispatched, date: nil, title: "Dispatched", description: "Your item will be handed to courier partner.", isCompleted: false),
                TrackingStep(status: .delivered, date: nil, title: "Delivered", description: "Estimated delivery.", isCompleted: false)
            ],
            estimatedDelivery: Date().addingTimeInterval(86400 * 3) // 3 days
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Push to active orders globally
            ordersManager.addOrder(newOrder)
            // Empty the cart globally
            cartManager.clearCart()
            
            // Pop to root (Usually handled via NavigationPath, but we just simulate close/reset here)
            // Or since the cart is empty, navigating back would show the empty cart screen.
            NotificationCenter.default.post(name: NSNotification.Name("ResetToHome"), object: nil)
        }
    }
}
