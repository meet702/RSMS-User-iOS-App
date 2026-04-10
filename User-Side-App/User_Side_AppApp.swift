//
//  User_Side_AppApp.swift
//  User-Side-App
//
//  Created by Apple on 10/04/26.
//

import SwiftUI

@main
struct User_Side_AppApp: App {
    @State private var cartManager = CartManager()
    @State private var wishlistManager = WishlistManager()
    @State private var ordersManager = OrdersManager()
    @State private var profileManager = ProfileManager()
    @State private var userManager = UserManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cartManager)
                .environment(wishlistManager)
                .environment(ordersManager)
                .environment(profileManager)
                .environment(userManager)
        }
    }
}
