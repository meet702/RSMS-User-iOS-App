//
//  NavigationManager.swift
//  User-Side-App
//
//  Global navigation and state manager for DIOR
//

import SwiftUI

@Observable
class NavigationManager {
    // Current active tab (4 tabs — Profile is a modal, not a tab)
    var selectedTab: MainTabView.AppTab = .home
    
    // Sheet presentation states
    var showNotifications = false
    var showAppointments = false
    var showProfile = false
    
    // Transition states — set before switching tabs
    var pendingCategoryFilter: String? = nil
    var pendingSearchText: String? = nil
    
    func navigateToShop(withCategory category: String? = nil, search: String? = nil) {
        pendingCategoryFilter = category
        pendingSearchText = search
        withAnimation {
            selectedTab = .shop
        }
    }
    
    func navigateToOrders() {
        withAnimation {
            selectedTab = .orders
        }
    }
    
    func navigateToCart() {
        withAnimation {
            selectedTab = .cart
        }
    }
}
