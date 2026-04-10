//
//  MainTabView.swift
//  User-Side-App
//
//  LUXE — iOS 26 Liquid Glass tab navigation
//

import SwiftUI

struct MainTabView: View {
    @Environment(NavigationManager.self) private var navManager
    @Environment(CartManager.self) private var cartManager
    
    enum AppTab: Hashable {
        case home, shop, cart, orders, profile
    }
    
    var body: some View {
        TabView(selection: Bindable(navManager).selectedTab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            
            Tab("Shop", systemImage: "bag.fill", value: AppTab.shop) {
                ShopView()
            }
            
            Tab("Cart", systemImage: "cart.fill", value: AppTab.cart) {
                CartView()
            }
            .badge(cartManager.totalItems)
            
            Tab("Orders", systemImage: "shippingbox.fill", value: AppTab.orders) {
                OrdersView()
            }
            
            Tab("Profile", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(AppColors.gold)
        .sheet(isPresented: Bindable(navManager).showNotifications) {
            NotificationSheet()
        }
        .sheet(isPresented: Bindable(navManager).showAppointments) {
            AppointmentSheet()
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
        .environment(CartManager())
        .environment(WishlistManager())
}
