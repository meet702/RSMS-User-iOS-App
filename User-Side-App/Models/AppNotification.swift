//  AppNotification.swift
//  User-Side-App
//  Domain model for in-app notifications

import Foundation

struct AppNotification: Identifiable, Hashable {
    let id: UUID
    let title: String
    let message: String
    let icon: String // Fallback handled
    var isRead: Bool
    let createdAt: Date

    // Formatting helper
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
