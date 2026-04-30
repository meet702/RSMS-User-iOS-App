//  NotificationManager.swift
//  User-Side-App
//  Supabase Realtime Notifications Engine

import Foundation
import Supabase
import SwiftUI

@MainActor
@Observable
class NotificationManager {
    static let shared = NotificationManager()

    var notifications: [AppNotification] = []

    // Computed property for UI badging
    var hasUnreadNotifications: Bool {
        notifications.contains(where: { !$0.isRead })
    }

    private var client: SupabaseClient { SupabaseManager.shared.client }
    private var channel: RealtimeChannelV2?
    private var listeningTask: Task<Void, Never>?

    private init() {}

    /// Called when the user logs in or app starts with a valid session
    func setup(userId: UUID) {
        Task {
            await fetchExistingNotifications(userId: userId)
            startListening(userId: userId)
        }
    }

    /// Called when user logs out
    func clear() {
        listeningTask?.cancel()
        listeningTask = nil
        Task {
            if let channel = channel {
                await client.removeChannel(channel)
            }
            channel = nil
            notifications = []
        }
    }

    private func fetchExistingNotifications(userId: UUID) async {
        do {
            let dtos: [NotificationDTO] = try await client
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            self.notifications = dtos.compactMap { dtoToModel($0) }
        } catch {
            print("Failed to fetch existing notifications: \(error)")
        }
    }

    private func startListening(userId: UUID) {
        listeningTask?.cancel() // Cancel previous if any

        let newChannel = client.channel("notifications_channel_\(userId.uuidString)")
        self.channel = newChannel

        // Setup the WebSocket listener exactly aligned to this user's rows
        let insertions = newChannel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId.uuidString)"
        )

        listeningTask = Task {
            await newChannel.subscribe()

            // This is an AsyncSequence that will run infinitely while subscribed!
            for await change in insertions {
                do {
                    let dto = try change.decodeRecord(as: NotificationDTO.self, decoder: JSONDecoder())
                    if let newNotif = self.dtoToModel(dto) {
                        // Insert at the top so it pops up immediately!
                        withAnimation {
                            self.notifications.insert(newNotif, at: 0)
                        }
                    }
                } catch {
                    print("Failed to decode realtime notification: \(error)")
                }
            }
        }
    }

    func markAllAsRead(userId: UUID) {
        // Optimistic UI update instantly!
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }

        // Background push to server
        Task {
            do {
                try await client
                    .from("notifications")
                    .update(["is_read": true])
                    .eq("user_id", value: userId)
                    .execute()
            } catch {
                print("Failed to backend sync read status: \(error)")
            }
        }
    }

    // MARK: - Handlers

    private func dtoToModel(_ dto: NotificationDTO) -> AppNotification? {
        // ISO8601 parsing handles standard PostgreSQL timestamps if strictly formatted
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var parsedDate = Date()
        if let creationString = dto.created_at {
            if let d = formatter.date(from: creationString) {
                parsedDate = d
            } else {
                formatter.formatOptions = [.withInternetDateTime]
                if let d2 = formatter.date(from: creationString) {
                    parsedDate = d2
                }
            }
        }

        return AppNotification(
            id: dto.id,
            title: dto.title,
            message: dto.message,
            icon: dto.icon ?? "bell.fill",
            isRead: dto.is_read,
            createdAt: parsedDate
        )
    }
}
