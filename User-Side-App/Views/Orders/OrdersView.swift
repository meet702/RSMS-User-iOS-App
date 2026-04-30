//  OrdersView.swift
//  User-Side-App
//  Main Orders Tab  displays active and past orders list with cancel logic

import SwiftUI

struct OrdersView: View {
    @Environment(OrdersManager.self) private var ordersManager
    @Environment(UserManager.self) private var userManager

    @State private var selectedTab: OrderTab = .active

    enum OrderTab: String, CaseIterable {
        case active = "My Orders"
        case past = "Past Orders"
    }

    private var currentOrders: [Order] {
        selectedTab == .active ? ordersManager.activeOrders : ordersManager.pastOrders
    }

    var body: some View {
        VStack(spacing: 0) {
                // Segmented Control
                segmentedPicker
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(AppColors.background)

                // List of Orders
                ScrollView(.vertical, showsIndicators: false) {
                    if currentOrders.isEmpty && ordersManager.isLoading {
                        loadingState
                    } else if currentOrders.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(currentOrders) { order in
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
                .refreshable {
                    if let userId = userManager.supabaseUserId {
                        await ordersManager.loadOrders(userId: userId)
                    }
                }
            }
            .task {
                if let userId = userManager.supabaseUserId {
                    await ordersManager.loadOrders(userId: userId)
                }
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
                    try await ordersManager.cancelOrder(order.id)
                    // Auto-switch to past tab to show the cancelled order landing
                    withAnimation(.easeInOut) {
                        selectedTab = .past
                    }
                }
            }
        }

    // MARK: - Segmented Picker

    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(OrderTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .bold : .medium)
                        .foregroundStyle(selectedTab == tab ? AppColors.pureWhite : AppColors.grayLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if selectedTab == tab {
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

    // MARK: - States

    private var loadingState: some View {
        VStack {
            Spacer().frame(height: 100)
            ProgressView()
                .progressViewStyle(.circular)
                .tint(AppColors.gold)
                .scaleEffect(1.5)
            Text("Fetching your orders...")
                .font(.caption)
                .foregroundStyle(AppColors.grayLight)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }

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
                Text("No \(selectedTab.rawValue)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)

                Text(selectedTab == .active
                     ? "You don't have any active orders right now.\nStart shopping to place an order!"
                     : "You haven't made any purchases yet.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if selectedTab == .active {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                    Text("Browse the Shop tab to place an order")
                        .font(.caption)
                }
                .foregroundStyle(AppColors.gold.opacity(0.6))
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

#Preview {
    OrdersView()
        .withLuxePreviewEnvironment()
}
