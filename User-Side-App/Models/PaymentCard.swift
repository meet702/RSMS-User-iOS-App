//
//  PaymentCard.swift
//  User-Side-App
//
//  Saved payment card model for LUXE
//

import Foundation

enum CardNetwork: String, Codable, Sendable {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case amex = "Amex"
    case unknown = "Card"
}

struct PaymentCard: Identifiable, Hashable, Sendable {
    let id: UUID
    var cardholderName: String
    var cardNumber: String // Storing full number for mock, in reality just last 4
    var expiryDate: String
    var cvv: String // In reality, do not store CVV
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        cardholderName: String,
        cardNumber: String,
        expiryDate: String,
        cvv: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvv = cvv
        self.isDefault = isDefault
    }
    
    var last4: String {
        guard cardNumber.count >= 4 else { return cardNumber }
        return String(cardNumber.suffix(4))
    }
    
    var network: CardNetwork {
        if cardNumber.hasPrefix("4") { return .visa }
        if cardNumber.hasPrefix("5") { return .mastercard }
        if cardNumber.hasPrefix("34") || cardNumber.hasPrefix("37") { return .amex }
        return .unknown
    }
}
