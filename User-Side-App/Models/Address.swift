//
//  Address.swift
//  User-Side-App
//
//  Delivery address model for LUXE
//

import Foundation

struct Address: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var phoneNumber: String
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        street: String,
        city: String,
        state: String,
        zipCode: String,
        phoneNumber: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.phoneNumber = phoneNumber
        self.isDefault = isDefault
    }
    
    var formattedAddress: String {
        return "\(street), \(city), \(state) \(zipCode)"
    }
}
