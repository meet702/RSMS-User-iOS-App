//
//  OrdersView.swift
//  User-Side-App
//
//  Main Orders Tab — displays active and past orders list with cancel logic
//

import SwiftUI

struct OrdersView: View {
    @Environment(OrdersManager.self) private var ordersManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                segmentedPicker
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(AppColors.background)
                
                // List of Orders
                ScrollView(.vertical, showsIndicators: false) {
                    if ordersManager.currentOrders.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(ordersManager.currentOrders) { order in
                                NavigationLink(value: order) {
                                    OrderCardView(order: order)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Color.clear.frame(height: 80) // Tab bar clearance
                    }
                }
                .background(AppColors.background)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MY ORDERS")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.gold)
                }
            }
            .navigationDestination(for: Order.self) { order in
                OrderTrackingView(order: order) {
                    ordersManager.cancelOrder(order.id)
                }
            }
        }
    }
    
    // MARK: - Segmented Picker
    
    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(OrdersManager.OrderTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        ordersManager.selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(ordersManager.selectedTab == tab ? .bold : .medium)
                        .foregroundStyle(ordersManager.selectedTab == tab ? AppColors.pureWhite : AppColors.grayLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if ordersManager.selectedTab == tab {
                                    Capsule()
                                        .fill(AppColors.surfaceDark)
                                        .overlay(Capsule().stroke(AppColors.gold.opacity(0.3), lineWidth: 1))
                                    
                                    // Subtle indicator glow
                                    Capsule()
                                        .fill(AppColors.gold)
                                        .frame(height: 2)
                                        .offset(y: 18)
                                        .frame(width: 30) // Indicator width
                                }
                            }
                        )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
        .padding(4)
        .background(AppColors.surfaceElevated.opacity(0.5))
        .clipShape(Capsule())
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)
            
            ZStack {
                Circle()
                    .fill(AppColors.surfaceDark)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "shippingbox")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
            }
            
            VStack(spacing: 8) {
                Text("No \(ordersManager.selectedTab.rawValue)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text(ordersManager.selectedTab == .active
                     ? "You don't have any active orders right now.\nStart shopping to place an order!"
                     : "You haven't made any purchases yet.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            if ordersManager.selectedTab == .active {
                // Return to shopping (Navigation routing would go back to home or shop tab)
                Button(action: {
                    // In a fully integrated app layout, you could inject selectedTab via environment
                    // and switch to .shop Tab. 
                }) {
                    Text("START SHOPPING")
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(1)
                        .foregroundStyle(AppColors.gold)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .overlay(Capsule().stroke(AppColors.gold, lineWidth: 1))
                }
                .buttonStyle(PressButtonStyle())
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

#Preview {
    OrdersView()
        .preferredColorScheme(.dark)
        .environment(OrdersManager())
}
