//
//  OrderSuccessView.swift
//  User-Side-App
//
//  LUXE Order Confirmation — Post-purchase celebration
//

import SwiftUI

struct OrderSuccessView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(NavigationManager.self) private var navManager
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil
    
    @State private var animateIcon = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated Success Icon
                ZStack {
                    Circle()
                        .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(LinearGradient.goldSubtle)
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateIcon ? 1 : 0.8)
                        .opacity(animateIcon ? 1 : 0)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .opacity(animateIcon ? 1 : 0)
                }
                
                VStack(spacing: 16) {
                    Text("PURCHASE COMPLETE")
                        .font(.title2)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.pureWhite)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                    
                    Text("Your luxury items are being prepared for shipment. A confirmation email has been sent to your registered address.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                }
                
                Spacer()
                
                // Back to Shop Button
                Button(action: { finalizePurchase() }) {
                    Text("BACK TO SHOP")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.2)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showText = true
            }
        }
    }
    
    private func finalizePurchase() {
        // Clear cart
        cartManager.clearCart()
        
        // Navigate to Orders Tab
        navManager.selectedTab = .orders
        
        onComplete?()
        dismiss()
    }
}

#Preview {
    OrderSuccessView()
        .environment(NavigationManager())
        .withLuxePreviewEnvironment()
}
