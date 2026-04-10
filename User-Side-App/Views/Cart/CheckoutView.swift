//
//  CheckoutView.swift
//  User-Side-App
//
//  LUXE Checkout experience — Address, Payment, Summary
//

import SwiftUI

struct CheckoutView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    
    // Internal state for simulation
    @State private var selectedAddress = "Home — 123 Luxury Lane, Beverly Hills"
    @State private var selectedPayment = "LUXE Card •••• 8888"
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Section 1: Shipping
                        checkoutSection(title: "SHIPPING ADDRESS") {
                            addressCard
                        }
                        
                        // Section 2: Payment
                        checkoutSection(title: "PAYMENT METHOD") {
                            paymentCard
                        }
                        
                        // Section 3: Order Summary
                        checkoutSection(title: "ORDER SUMMARY") {
                            orderSummaryCard
                        }
                        
                        // Extra spacing
                        Color.clear.frame(height: 120)
                    }
                    .padding(20)
                }
                
                // Place Order Button
                placeOrderFooter
            }
            .navigationTitle("CHECKOUT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.grayLight)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("CHECKOUT")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.gold)
                }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                OrderSuccessView(onComplete: {
                    dismiss()
                })
            }
        }
    }
    
    // MARK: - Components
    
    private func checkoutSection<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColors.grayMedium)
            
            content()
        }
    }
    
    private var addressCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(AppColors.gold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedAddress)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text("Standard Delivery: 3-5 Business Days")
                    .font(.caption2)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.grayMedium)
        }
        .padding(16)
        .darkCard(goldBorder: true)
    }
    
    private var paymentCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.title2)
                .foregroundStyle(AppColors.gold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedPayment)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text(cartManager.subtotal.formattedPrice)
                    .font(.caption2)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.grayMedium)
        }
        .padding(16)
        .darkCard(goldBorder: true)
    }
    
    private var orderSummaryCard: some View {
        VStack(spacing: 12) {
            ForEach(cartManager.items.prefix(3)) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(item.totalPrice.formattedPrice)
                        .font(.caption)
                        .foregroundStyle(AppColors.pureWhite)
                }
            }
            
            if cartManager.items.count > 3 {
                Text("+ \(cartManager.items.count - 3) more items")
                    .font(.caption2)
                    .foregroundStyle(AppColors.gold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            HStack {
                Text("TOTAL AMOUNT")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Spacer()
                
                Text(cartManager.subtotal.formattedPrice)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(16)
        .darkCard(goldBorder: false)
    }
    
    private var placeOrderFooter: some View {
        VStack {
            Button(action: { placeOrder() }) {
                HStack(spacing: 12) {
                    Text("PLACE ORDER")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient.goldSubtle)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 34)
            .background(
                AppColors.background
                    .shadow(color: .black.opacity(0.4), radius: 10, y: -5)
            )
        }
    }
    
    // MARK: - Actions
    
    private func placeOrder() {
        // Here we would typically hit an API
        // For simulation, we wait a bit then show success
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            showSuccess = true
        }
    }
}

#Preview {
    CheckoutView()
        .environment(CartManager())
}
