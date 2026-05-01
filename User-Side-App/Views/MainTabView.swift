//
//  MainTabView.swift
//  User-Side-App
//
//  DIOR — iOS 26 Liquid Glass tab navigation (4 tabs)
//  Profile is presented as a modal from the Home header.
//

import SwiftUI

struct MainTabView: View {
    @Environment(NavigationManager.self) private var navManager
    @Environment(CartManager.self) private var cartManager
    
    enum AppTab: Hashable {
        case home, shop, cart, orders
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
                NavigationStack {
                    OrdersView()
                }
            }
        }
        .tint(AppColors.gold)
        .blur(radius: navManager.isAnyModalShowing ? 15 : 0)
        .animation(.easeInOut(duration: 0.35), value: navManager.isAnyModalShowing)
        .sheet(isPresented: Bindable(navManager).showNotifications) {
            NotificationSheet()
        }
        .sheet(isPresented: Bindable(navManager).showAppointments) {
            AppointmentSheet()
        }
        .sheet(isPresented: Bindable(navManager).showProfile) {
            ProfileView()
        }
        .sheet(isPresented: Bindable(navManager).showOffers) {
            OfferSheet(offers: navManager.activeOffers)
        }
    }
}

#Preview {
    MainTabView()
        .withLuxePreviewEnvironment()
}
