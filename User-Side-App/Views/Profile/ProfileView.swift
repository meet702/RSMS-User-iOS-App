//
//  ProfileView.swift
//  User-Side-App
//

import SwiftUI

struct ProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(ThemeManager.self) private var themeManager
    @Environment(NavigationManager.self) private var navManager
    @Environment(OrdersManager.self) private var ordersManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditProfile = false
    @State private var addressCount = 0
    @State private var navigateToAddresses = false
    @State private var navigateToOrders = false
    @State private var navigateToWishlist = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        profileHeader
                        statsSection
                        menuSection
                        logoutButton
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .navigationTitle("PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MY DIOR")
                        .font(.headline).fontWeight(.bold).tracking(6).foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.gold)
                }
            }
            .navigationDestination(for: ProfileDestination.self) { dest in
                dest.view(navManager: navManager)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environment(userManager)
                    .environment(ordersManager)
            }
            .navigationDestination(isPresented: $navigateToOrders) {
                OrdersView()
            }
            .navigationDestination(isPresented: $navigateToWishlist) {
                WishlistView()
            }
            .task {
                if let userId = userManager.supabaseUserId {
                    async let addressesTask = SyncManager.shared.fetchAddresses(userId: userId)
                    async let ordersTask = ordersManager.loadOrders(userId: userId)
                    
                    if let addresses = try? await addressesTask {
                        await MainActor.run { addressCount = addresses.count }
                    }
                    _ = await ordersTask
                }
            }
            .navigationDestination(isPresented: $navigateToAddresses) {
                ShippingAddressListView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    if let url = userManager.currentUser?.avatarURL {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView().tint(AppColors.alwaysBlack)
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                    } else {
                        Circle().fill(LinearGradient.goldSubtle).frame(width: 90, height: 90)
                        Text(userManager.currentUser?.initials ?? "??")
                            .font(.title).fontWeight(.bold).foregroundStyle(AppColors.alwaysBlack)
                    }
                }
                .overlay(Circle().stroke(AppColors.gold.opacity(0.3), lineWidth: 4))
                
                Button(action: { showEditProfile = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .padding(7)
                        .background(AppColors.gold)
                        .clipShape(Circle())
                        .shadow(color: AppColors.gold.opacity(0.5), radius: 4)
                }
                .offset(x: 2, y: 2)
            }
            .padding(.top, 20)
            
            VStack(spacing: 4) {
                Text(userManager.currentUser?.fullName ?? "Guest User")
                    .font(.title3).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                Text(userManager.currentUser?.email ?? "")
                    .font(.caption).foregroundStyle(AppColors.grayLight)
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            statItem(label: "Orders", value: "\(ordersManager.totalOrders)") {
                navigateToOrders = true
            }
            statDivider
            statItem(label: "Wishlist", value: "\(wishlistManager.count)") {
                navigateToWishlist = true
            }
            statDivider
            statItem(label: "Addresses", value: "\(addressCount)") {
                navigateToAddresses = true
            }
        }
        .padding(.vertical, 24).padding(.horizontal, 32)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 20)
    }
    
    private func statItem(label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(value).font(.title3).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                Text(label).font(.caption2).foregroundStyle(AppColors.grayLight).tracking(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private var statDivider: some View {
        Rectangle().fill(AppColors.grayDark.opacity(0.3)).frame(width: 1, height: 30)
    }
    
    // MARK: - Menu Section
    
    private var menuSection: some View {
        VStack(spacing: 24) {
            menuGroup(title: "SHOPPING") {
                ProfileMenuRow(icon: "bag.fill", title: "My Orders", destination: .orderHistory)
                ProfileMenuRow(icon: "mappin.and.ellipse", title: "Saved Addresses", destination: .shippingAddresses)
            }
            
            appearanceSection
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        @Bindable var themeManager = themeManager
        
        return menuGroup(title: "APPEARANCE") {
            HStack(spacing: 16) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 18)).foregroundStyle(AppColors.gold.opacity(0.8)).frame(width: 24)
                Text("Theme").font(.subheadline).foregroundStyle(AppColors.pureWhite)
                Spacer()
                Picker("", selection: $themeManager.selectedTheme) {
                    ForEach(ThemeManager.AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu).accentColor(AppColors.gold)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            
            Divider().background(AppColors.grayDark.opacity(0.3)).padding(.leading, 56)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 18)).foregroundStyle(AppColors.gold.opacity(0.8)).frame(width: 24)
                    Text("Language & Region").font(.subheadline).foregroundStyle(AppColors.pureWhite)
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 14)).foregroundStyle(AppColors.grayLight)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func menuGroup<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption2).fontWeight(.bold).tracking(2)
                .foregroundStyle(AppColors.grayMedium).padding(.leading, 8)
            
            VStack(spacing: 1) { content() }
                .background(AppColors.surfaceDark)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
        }
    }
    
    // MARK: - Logout
    
    private var logoutButton: some View {
        Button(action: { userManager.logout() }) {
            Text("LOG OUT")
                .font(.subheadline).fontWeight(.bold).tracking(2)
                .foregroundStyle(Color.red.opacity(0.8)).padding(.vertical, 16)
        }
    }
}

// MARK: - Profile Navigation Destinations

enum ProfileDestination: Hashable {
    case orderHistory, shippingAddresses
    
    @ViewBuilder
    func view(navManager: NavigationManager) -> some View {
        switch self {
        case .orderHistory:
            OrdersView()
        case .shippingAddresses:
            ShippingAddressListView()
        }
    }
}

struct ProfileDetailPlaceholderView: View {
    let destination: ProfileDestination
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(AppColors.surfaceGold.opacity(0.4)).frame(width: 100, height: 100)
                    Image(systemName: destination.iconName)
                        .font(.system(size: 36, weight: .light)).foregroundStyle(AppColors.gold)
                }
                
                VStack(spacing: 8) {
                    Text(destination.title).font(.title3).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                    Text("This feature is coming soon.\nWe're building something beautiful for you.")
                        .font(.subheadline).foregroundStyle(AppColors.grayLight)
                        .multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal, 40)
                }
                
                Button(action: { dismiss() }) {
                    Text("GO BACK")
                        .font(.caption).fontWeight(.bold).tracking(2).foregroundStyle(AppColors.gold)
                        .padding(.horizontal, 32).padding(.vertical, 14)
                        .overlay(Capsule().stroke(AppColors.gold, lineWidth: 1.5))
                }
                .buttonStyle(PressButtonStyle())
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(destination.title.uppercased())
                    .font(.headline).fontWeight(.bold).tracking(4).foregroundStyle(AppColors.gold)
            }
        }
    }
}

extension ProfileDestination {
    var title: String {
        switch self {
        case .orderHistory:       return "My Orders"
        case .shippingAddresses:  return "Saved Addresses"
        }
    }
    
    var iconName: String {
        switch self {
        case .orderHistory:       return "bag.fill"
        case .shippingAddresses:  return "mappin.and.ellipse"
        }
    }
}

// MARK: - Profile Menu Row

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let destination: ProfileDestination
    
    var body: some View {
        NavigationLink(value: destination) {
            rowContent
        }
        .buttonStyle(.plain)
    }
    
    private var rowContent: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18)).foregroundStyle(AppColors.gold.opacity(0.8)).frame(width: 24)
            Text(title).font(.subheadline).foregroundStyle(AppColors.pureWhite)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(AppColors.grayDark)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
        .withLuxePreviewEnvironment()
}
