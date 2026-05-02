//
//  CartView.swift
//  User-Side-App
//
//  Cart tab placeholder — Phase 3
//

import SwiftUI

struct CartView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(UserManager.self) private var userManager
    @State private var showCheckout = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColors.background.ignoresSafeArea()
                
                if cartManager.items.isEmpty {
                    emptyCartView
                } else {
                    cartContent
                }
                
                if !cartManager.items.isEmpty {
                    checkoutFooter
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CART")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(6)
                        .foregroundStyle(AppColors.gold)
                }
            }
            .fullScreenCover(isPresented: $showCheckout) {
                CheckoutView()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyCartView: some View {
        VStack {
            Spacer()
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceGold.opacity(0.25))
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(AppColors.gold.opacity(0.15), lineWidth: 1)
                        .frame(width: 120, height: 120)
                    Image(systemName: "cart")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundStyle(LinearGradient.goldSubtle)
                }
                
                VStack(spacing: 10) {
                    Text("Your bag is empty")
                        .font(.title3).fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    Text("Explore our exclusive collection\nand start your DIOR journey.")
                        .font(.subheadline).foregroundStyle(AppColors.grayLight)
                        .multilineTextAlignment(.center).lineSpacing(4)
                }
                
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, AppColors.gold.opacity(0.4), .clear],
                                        startPoint: .leading, endPoint: .trailing))
                    .frame(height: 1).padding(.horizontal, 60)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Cart Content
    
    private var cartContent: some View {
        List {
            ForEach(cartManager.items) { item in
                CartItemRow(item: item)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    cartManager.removeFromCart(item: cartManager.items[index], userId: userManager.supabaseUserId)
                }
            }
            
            // Extra space for footer
            Color.clear.frame(height: 180)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Checkout Footer
    
    private var checkoutFooter: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(cartManager.subtotal.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.pureWhite)
                }
                
                HStack {
                    Text("Delivery")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text("Complimentary")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(1)
                        .foregroundStyle(AppColors.gold)
                }
                
                Rectangle()
                    .fill(AppColors.grayDark.opacity(0.3))
                    .frame(height: 0.5)
                
                HStack {
                    Text("Estimated Total")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    Spacer()
                    Text(cartManager.subtotal.formattedPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.gold)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Subtotal: \(cartManager.subtotal.formattedPrice). Delivery: Complimentary. Estimated Total: \(cartManager.subtotal.formattedPrice)")
            
            // Checkout button
            Button(action: { showCheckout = true }) {
                Text("PROCEED TO CHECKOUT")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient.goldSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(PressButtonStyle())
        }
        .padding(24)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(AppColors.surfaceDark)
                .shadow(color: .black.opacity(0.5), radius: 15, y: -5)
        )
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .stroke(AppColors.gold.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    let item: CartItem
    @Environment(CartManager.self) private var cartManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image — AsyncProductImage handles URL + fallback
            AsyncProductImage(product: item.product)
                .frame(width: 90, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .goldBorder(cornerRadius: 12)
            
            // Item Info
            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.brand)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(AppColors.gold)
                
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                    .lineLimit(1)
                
                if let variant = item.variant {
                    Text(variant)
                        .font(.caption2)
                        .foregroundStyle(AppColors.grayLight)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.grayDark.opacity(0.3))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    Text((item.product.price * Double(item.quantity)).formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.gold)
                    
                    Spacer()
                    
                    // Quantity management
                    HStack(spacing: 12) {
                        Button(action: {
                            cartManager.updateQuantity(for: item, quantity: item.quantity - 1, userId: userManager.supabaseUserId)
                        }) {
                            Image(systemName: item.quantity == 1 ? "trash" : "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(item.quantity == 1 ? Color.red.opacity(0.8) : AppColors.pureWhite)
                                .frame(width: 28, height: 28)
                                .background(AppColors.surfaceElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.quantity == 1 ? "Remove item" : "Decrease quantity")
                        
                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.pureWhite)
                            .frame(minWidth: 20)
                        
                        Button(action: {
                            cartManager.updateQuantity(for: item, quantity: item.quantity + 1, userId: userManager.supabaseUserId)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .frame(width: 28, height: 28)
                                .background(AppColors.gold)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Increase quantity")
                    }
                    .padding(4)
                    .background(AppColors.surfaceDark)
                    .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)
        }
        .accessibilityElement(children: .contain)
        .padding(12)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
    

}

#Preview {
    CartView()
        .withLuxePreviewEnvironment()
}
