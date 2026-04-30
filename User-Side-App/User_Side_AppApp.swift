//  User_Side_AppApp.swift
//  User-Side-App
//  Created by Apple on 10/04/26.

import SwiftUI

@main
struct User_Side_AppApp: App {
    @State private var cartManager = CartManager()
    @State private var wishlistManager = WishlistManager()
    @State private var userManager = UserManager()
    @State private var navManager = NavigationManager()
    @State private var themeManager = ThemeManager()
    @State private var ordersManager = OrdersManager()
    @State private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cartManager)
                .environment(wishlistManager)
                .environment(userManager)
                .environment(navManager)
                .environment(themeManager)
                .environment(ordersManager)
                .environment(notificationManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .onOpenURL { url in
                    print("[App] Received URL: \(url.absoluteString)")
                    Task {
                        await userManager.handleOAuthCallback(url: url)
                    }
                }
                .task {
                    // Fetch exchange rates
                    await CurrencyManager.shared.fetchRates()
                    // Restore session on launch
                    await userManager.checkSession()
                }
                .onChange(of: userManager.isAuthenticated) { oldValue, newValue in
                    if newValue {
                        // Sync user-specific data on login
                        if let userId = userManager.supabaseUserId {
                            Task {
                                await cartManager.loadCart(userId: userId)
                                await wishlistManager.loadWishlist(userId: userId)
                                await ordersManager.loadOrders(userId: userId)
                            }
                            notificationManager.setup(userId: userId)
                        }
                    } else {
                        // Clear state on logout
                        cartManager.clearCart()
                        wishlistManager.items.removeAll()
                        ordersManager.orders.removeAll()
                        notificationManager.clear()
                    }
                }
        }
    }
}
