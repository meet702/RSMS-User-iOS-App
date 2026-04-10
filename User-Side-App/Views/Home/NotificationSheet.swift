//
//  NotificationSheet.swift
//  User-Side-App
//
//  LUXE Notifications — Order updates and exclusive invitations
//

import SwiftUI

struct NotificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        notificationRow(
                            icon: "shippingbox.fill",
                            title: "Order Shipped",
                            message: "Your order #LX-9021 for the Submariner Date has been shipped.",
                            time: "2h ago",
                            isNew: true
                        )
                        
                        notificationRow(
                            icon: "sparkles",
                            title: "Exclusive Invitation",
                            message: "You are invited to our private viewing of the Summer Collection.",
                            time: "1d ago",
                            isNew: false
                        )
                        
                        notificationRow(
                            icon: "crown.fill",
                            title: "Loyalty Update",
                            message: "You've earned 500 bonus points for your recent purchase.",
                            time: "3d ago",
                            isNew: false
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle("NOTIFICATIONS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
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
