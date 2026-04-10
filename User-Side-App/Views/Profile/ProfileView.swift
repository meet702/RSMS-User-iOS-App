//
//  ProfileView.swift
//  User-Side-App
//
//  Profile tab placeholder — Phase 4
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WishlistManager.self) private var wishlistManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Profile Header
                        profileHeader
                        
                        // Stats Section
                        statsSection
                        
                        // Operations Menu
                        menuSection
                        
                        // Logout Button
                        logoutButton
                        
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .navigationTitle("PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MY LUXE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(6)
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient.goldSubtle)
                    .frame(width: 90, height: 90)
                
                Text(userManager.currentUser?.initials ?? "??")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.background)
            }
            .overlay(
                Circle()
                    .stroke(AppColors.gold.opacity(0.3), lineWidth: 4)
            )
            .padding(.top, 20)
            
            VStack(spacing: 4) {
                Text(userManager.currentUser?.fullName ?? "Guest User")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text(userManager.currentUser?.email ?? "")
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            // Tier Badge
            if let user = userManager.currentUser {
                HStack(spacing: 6) {
                    Image(systemName: user.tier.icon)
                    Text(user.tier.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(1)
                }
                .foregroundStyle(AppColors.background)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.gold)
                .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            statItem(label: "Orders", value: "\(userManager.currentUser?.ordersCount ?? 0)")
            statDivider
            statItem(label: "Wishlist", value: "\(wishlistManager.count)")
            statDivider
            statItem(label: "Points", value: "\(userManager.currentUser?.points ?? 0)")
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.pureWhite)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.grayLight)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var statDivider: some View {
        Rectangle()
            .fill(AppColors.grayDark.opacity(0.3))
            .frame(width: 1, height: 30)
    }
    
    // MARK: - Menu Section
    
    private var menuSection: some View {
        VStack(spacing: 24) {
            // Shopping Group
            menuGroup(title: "SHOPPING") {
                ProfileMenuRow(icon: "bag.fill", title: "Order History")
                ProfileMenuRow(icon: "creditcard.fill", title: "Payment Methods")
                ProfileMenuRow(icon: "mappin.and.ellipse", title: "Shipping Addresses")
            }
            
            // Experience Group
            menuGroup(title: "LUXE EXPERIENCE") {
                ProfileMenuRow(icon: "sparkles", title: "Personal Concierge")
                ProfileMenuRow(icon: "hand.raised.fill", title: "Style Preferences")
                ProfileMenuRow(icon: "checkmark.seal.fill", title: "Authenticity Certificates")
            }
            
            // Support Group
            menuGroup(title: "SUPPORT") {
                ProfileMenuRow(icon: "questionmark.circle.fill", title: "Help Center")
                ProfileMenuRow(icon: "phone.fill", title: "Contact Us")
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func menuGroup<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(AppColors.grayMedium)
                .padding(.leading, 8)
            
            VStack(spacing: 1) {
                content()
            }
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Logout
    
    private var logoutButton: some View {
        Button(action: { userManager.logout() }) {
            Text("LOG OUT")
                .font(.subheadline)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(Color.red.opacity(0.8))
                .padding(.vertical, 16)
        }
    }
}

// MARK: - Profile Menu Row

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.gold.opacity(0.8))
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.pureWhite)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.grayDark)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
