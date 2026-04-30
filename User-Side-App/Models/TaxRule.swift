//  TaxRule.swift
//  User-Side-App
//  Data model for regional taxation rules in LUXE.

import Foundation

struct TaxRule: Identifiable, Hashable, Sendable {
    let id: UUID
    let storeId: UUID?
    let name: String
    let rate: Double
    let isInclusive: Bool
}
