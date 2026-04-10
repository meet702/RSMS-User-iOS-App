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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cartManager)
                .environment(wishlistManager)
        }
    }
}
