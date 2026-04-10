//
//  NavigationManager.swift
//  User-Side-App
//
//  Global navigation and state manager for LUXE
//

import SwiftUI

@Observable
class NavigationManager {
    // Current active tab
    var selectedTab: MainTabView.AppTab = .home
    
    // Sheet presentation states
    var showNotifications = false
    var showAppointments = false
    
    // Transition states
    var pendingCategoryFilter: String? = nil
    
    func navigateToShop(withCategory category: String? = nil) {
        pendingCategoryFilter = category
        withAnimation {
            selectedTab = .shop
        }
    }
    
    func navigateToProfile() {
        withAnimation {
            selectedTab = .profile
        }
    }
}
