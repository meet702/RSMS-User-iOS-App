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
    
    init() {
        // Initialize with a mock premium user for the LUXE experience
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
    
    func updateProfile(firstName: String, lastName: String, email: String) {
        currentUser?.firstName = firstName
        currentUser?.lastName = lastName
        currentUser?.email = email
    }
}
