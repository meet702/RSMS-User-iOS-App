//
//  UserManager.swift
//  User-Side-App
//
//  App-wide user state manager for LUXE
//

import SwiftUI

@Observable
class UserManager {
    var currentUser: User?
    var isAuthenticated: Bool = false
    
    init() {
        // Prepare mock user but keep authenticated false by default
        self.currentUser = User(
            id: UUID(),
            firstName: "Siddharth",
            lastName: "Malhotra",
            email: "s.malhotra@luxeglobal.com",
            tier: .platinum,
            points: 12500,
            ordersCount: 24
        )
    }
    
    func login() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = true
        }
    }
    
    func logout() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = false
        }
    }
    
    func updateProfile(firstName: String, lastName: String, email: String) {
        currentUser?.firstName = firstName
        currentUser?.lastName = lastName
        currentUser?.email = email
    }
}
