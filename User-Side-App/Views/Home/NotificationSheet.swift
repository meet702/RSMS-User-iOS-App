//  NotificationSheet.swift
//  User-Side-App
//  LUXE Notifications  Order updates and exclusive invitations

import SwiftUI

struct NotificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(UserManager.self) private var userManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if notificationManager.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.grayLight)
                        Text("No notifications yet.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.grayLight)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(notificationManager.notifications) { notif in
                                notificationRow(
                                    icon: notif.icon,
                                    title: notif.title,
                                    message: notif.message,
                                    time: notif.timeAgo,
                                    isNew: !notif.isRead
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("NOTIFICATIONS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        if let uid = userManager.supabaseUserId {
                            notificationManager.markAllAsRead(userId: uid)
                        }
                        dismiss()
                    }
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }

    private func notificationRow(icon: String, title: String, message: String, time: String, isNew: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceGold.opacity(0.3))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.gold)
            }
            .overlay(
                Circle()
                    .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)

                    Spacer()

                    Text(time)
                        .font(.caption2)
                        .foregroundStyle(AppColors.grayLight)
                }

                Text(message)
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
                    .lineLimit(2)
            }

            if isNew {
                Circle()
                    .fill(AppColors.gold)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(16)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NotificationSheet()
}
