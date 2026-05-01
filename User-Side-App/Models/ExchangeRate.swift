//
//  ExchangeRate.swift
//  User-Side-App
//

import Foundation

struct ExchangeRate: Codable, Identifiable {
    var id: String { currency_code }
    let currency_code: String
    let rate: Double
    let symbol: String
    let locale_id: String
}
