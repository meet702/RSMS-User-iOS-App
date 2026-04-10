//
//  ProfileManager.swift
//  User-Side-App
//
//  Manager handling addresses and payment methods globally
//

import SwiftUI

@Observable
class ProfileManager {
    var addresses: [Address] = []
    var savedCards: [PaymentCard] = []
    
    init() {
        // Add some mock data initially
        addresses = [
            Address(name: "John Doe", street: "123 Luxury Avenue, Apt 4B", city: "Mumbai", state: "MH", zipCode: "400001", phoneNumber: "+91 9876543210", isDefault: true)
        ]
        
        savedCards = [
            PaymentCard(cardholderName: "John Doe", cardNumber: "4111222233334444", expiryDate: "12/28", cvv: "123", isDefault: true)
        ]
    }
    
    // MARK: - Address Management
    
    func addAddress(_ address: Address) {
        var newAddress = address
        if addresses.isEmpty || newAddress.isDefault {
            setDefaultAddress(id: newAddress.id)
            newAddress.isDefault = true
        }
        addresses.append(newAddress)
    }
    
    func updateAddress(_ address: Address) {
        if let index = addresses.firstIndex(where: { $0.id == address.id }) {
            if address.isDefault {
                setDefaultAddress(id: address.id)
            }
            addresses[index] = address
        }
    }
    
    func deleteAddress(id: UUID) {
        addresses.removeAll { $0.id == id }
        if !addresses.isEmpty, !addresses.contains(where: { $0.isDefault }) {
            addresses[0].isDefault = true
        }
    }
    
    private func setDefaultAddress(id: UUID) {
        for i in 0..<addresses.count {
            addresses[i].isDefault = (addresses[i].id == id)
        }
    }
    
    var defaultAddress: Address? {
        addresses.first(where: { $0.isDefault }) ?? addresses.first
    }
    
    // MARK: - Card Management
    
    func addCard(_ card: PaymentCard) {
        var newCard = card
        if savedCards.isEmpty || newCard.isDefault {
            setDefaultCard(id: newCard.id)
            newCard.isDefault = true
        }
        savedCards.append(newCard)
    }
    
    func updateCard(_ card: PaymentCard) {
        if let index = savedCards.firstIndex(where: { $0.id == card.id }) {
            if card.isDefault {
                setDefaultCard(id: card.id)
            }
            savedCards[index] = card
        }
    }
    
    func deleteCard(id: UUID) {
        savedCards.removeAll { $0.id == id }
        if !savedCards.isEmpty, !savedCards.contains(where: { $0.isDefault }) {
            savedCards[0].isDefault = true
        }
    }
    
    private func setDefaultCard(id: UUID) {
        for i in 0..<savedCards.count {
            savedCards[i].isDefault = (savedCards[i].id == id)
        }
    }
    
    var defaultCard: PaymentCard? {
        savedCards.first(where: { $0.isDefault }) ?? savedCards.first
    }
}
