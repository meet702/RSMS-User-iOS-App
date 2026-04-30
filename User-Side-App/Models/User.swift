//  User.swift
//  User-Side-App
//  User profile model for LUXE  membership and tiers

import Foundation

enum MembershipTier: String, CaseIterable, Sendable {
    case platinum = "PLATINUM"
    case gold = "GOLD"
    case silver = "SILVER"
    case elite = "ELITE"

    var icon: String {
        switch self {
        case .platinum: return "crown.fill"
        case .gold: return "star.fill"
        case .silver: return "hexagon.fill"
        case .elite: return "sparkles"
        }
    }
}

struct User: Identifiable, Sendable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var tier: MembershipTier
    var avatarURL: URL?
    var loyaltyPoints: Int = 0

    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
}
