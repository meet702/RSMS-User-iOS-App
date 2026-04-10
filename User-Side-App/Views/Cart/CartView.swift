//
//  CartView.swift
//  User-Side-App
//
//  LUXE Cart tab showing added items and total price summary
//

import SwiftUI

struct CartView: View {
    @Environment(CartManager.self) private var cartManager
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    if cartManager.items.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 24) {
                            // Cart Items List
                            LazyVStack(spacing: 16) {
                                ForEach(cartManager.items) { item in
                                    CartItemRow(item: item)
                                }
                            }
                            
                            // Promo Code
                            promoCodeSection
                            
                            // Price Breakdown
                            priceBreakdownSection
                            
                            Color.clear.frame(height: 120) // Spacing for checkout button
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
                
                // Bottom Checkout Bar
                if !cartManager.items.isEmpty {
                    VStack {
                        NavigationLink(destination: CheckoutAddressView()) {
                            HStack {
                                Text("PROCEED TO CHECKOUT")
                                    .fontWeight(.bold)
                                    .tracking(2)
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline)
                            .foregroundStyle(AppColors.background)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(LinearGradient.goldSubtle)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(PressButtonStyle())
                    }
                    .padding(20)
                    .background(
                        AppColors.surfaceDark
                            .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SHOPPING CART")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
    
    // MARK: - Cart Item Row
    
    private struct CartItemRow: View {
        let item: CartItem
        @Environment(CartManager.self) private var cartManager
        
        var body: some View {
            HStack(spacing: 16) {
                // Image
                ZStack {
                    AppColors.surfaceGold
                    Image(systemName: item.product.imageName)
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(AppColors.gold)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(item.product.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.pureWhite)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation { cartManager.removeFromCart(id: item.id) }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.grayMedium)
                        }
                    }
                    
                    if let variant = item.variant {
                        Text("Size/Variant: \(variant)")
                            .font(.caption)
                            .foregroundStyle(AppColors.grayLight)
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(item.product.price.formattedPrice)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.gold)
                        
                        Spacer()
                        
                        // Stepper
                        HStack(spacing: 12) {
                            Button(action: {
                                if item.quantity > 1 {
                                    cartManager.updateQuantity(id: item.id, quantity: item.quantity - 1)
                                } else {
                                    withAnimation { cartManager.removeFromCart(id: item.id) }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.pureWhite)
                                    .frame(width: 24, height: 24)
                                    .background(AppColors.surfaceElevated)
                                    .clipShape(Circle())
                            }
                            
                            Text("\(item.quantity)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.pureWhite)
                                .frame(width: 20)
                            
                            Button(action: {
                                cartManager.updateQuantity(id: item.id, quantity: item.quantity + 1)
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.pureWhite)
                                    .frame(width: 24, height: 24)
                                    .background(AppColors.surfaceElevated)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            .padding(12)
            .darkCard()
        }
    }
    
    // MARK: - Components
    
    private var promoCodeSection: some View {
        HStack {
            Image(systemName: "tag")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.gold)
            
            Text("Apply Promo Code")
                .font(.subheadline)
                .foregroundStyle(AppColors.grayLight)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.grayMedium)
        }
        .padding(16)
        .darkCard()
    }
    
    private var priceBreakdownSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Subtotal")
                    .foregroundStyle(AppColors.grayLight)
                Spacer()
                Text(cartManager.subtotal.formattedPrice)
                    .foregroundStyle(AppColors.pureWhite)
            }
            .font(.subheadline)
            
            HStack {
                Text("Taxes (18%)")
                    .foregroundStyle(AppColors.grayLight)
                Spacer()
                Text(cartManager.taxes.formattedPrice)
                    .foregroundStyle(AppColors.pureWhite)
            }
            .font(.subheadline)
            
            HStack {
                Text("Delivery")
                    .foregroundStyle(AppColors.grayLight)
                Spacer()
                Text("Calculated at checkout")
                    .foregroundStyle(AppColors.grayMedium)
            }
            .font(.subheadline)
            
            Divider()
                .background(AppColors.grayDark.opacity(0.5))
                .padding(.vertical, 4)
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(AppColors.pureWhite)
                Spacer()
                Text((cartManager.subtotal + cartManager.taxes).formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(20)
        .darkCard()
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 100)
            
            ZStack {
                Circle()
                    .fill(AppColors.surfaceDark)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "cart")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
            }
            
            Text("Your Cart is Empty")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.pureWhite)
            
            Text("Looking for something luxurious?\nBrowse our collections to find your perfect match.")
                .font(.subheadline)
                .foregroundStyle(AppColors.grayLight)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Rectangle()
                .fill(AppColors.gold.opacity(0.3))
                .frame(width: 40, height: 1)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

#Preview {
    CartView()
        .environment(CartManager())
}
