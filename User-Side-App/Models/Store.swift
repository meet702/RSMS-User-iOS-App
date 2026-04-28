//
//  Store.swift
//  User-Side-App
//
//  Data model for a physical LUXE boutique location.
//

import Foundation

struct Store: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let city: String
    let country: String
    let code: String?
    let address: String?
    let phone: String?
    let email: String?
    let taxRate: Double?
    let isActive: Bool
    
    var fullDisplayAddress: String {
        return "\(address ?? ""), \(city), \(country)"
    }
}
