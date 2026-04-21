//
//  UserManager.swift
//  User-Side-App
//
//  App-wide user state manager for DIOR — backed by Supabase Auth
//

import SwiftUI
import Supabase
import AuthenticationServices

@MainActor
@Observable
class UserManager {
    var currentUser: User?
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var authError: String? = nil
    
    var supabaseUserId: UUID? = nil
    
    init() {
        // Session check is performed by .task in User_Side_AppApp
        // Do NOT call checkSession() here — it races with .task
    }
    
    // MARK: - Session Check
    
    func checkSession() async {
        isLoading = true
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            supabaseUserId = session.user.id
            
            // Fetch profile from customer_profiles — using SyncManager
            if let profile = try await SyncManager.shared.fetchProfile(userId: session.user.id) {
                currentUser = User(
                    id: profile.id,
                    firstName: profile.first_name,
                    lastName: profile.last_name,
                    email: profile.email,
                    tier: MembershipTier(rawValue: profile.tier) ?? .silver,
                    avatarURL: profile.avatar_url.flatMap { URL(string: $0) },
                    loyaltyPoints: profile.loyalty_points
                )
            } else {
                // Profile doesn't exist yet — create from auth metadata
                let email = session.user.email ?? ""
                currentUser = User(
                    id: session.user.id,
                    firstName: "",
                    lastName: "",
                    email: email,
                    tier: .silver
                )
            }
            
            withAnimation(.easeInOut(duration: 0.4)) {
                isAuthenticated = true
            }
        } catch {
            // No active session — this is normal on first launch
            print("[Auth] No active session: \(error.localizedDescription)")
            isAuthenticated = false
            currentUser = nil
        }
        isLoading = false
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async {
        isLoading = true
        authError = nil
        
        do {
            let result = try await SupabaseManager.shared.client.auth.signUp(
                email: email,
                password: password
            )
            
            let userId = result.user.id
            supabaseUserId = userId
            
            // Create customer profile — using SyncManager
            let profile = ProfileDTO(
                id: userId,
                first_name: firstName,
                last_name: lastName,
                email: email,
                phone: nil,
                tier: "SILVER",
                loyalty_points: 0,
                avatar_url: nil
            )
            
            do {
                try await SyncManager.shared.upsertProfile(profile)
            } catch {
                print("[Auth] Profile upsert failed (RLS?): \(error.localizedDescription)")
                // Continue — the profile table or RLS policy may not be set up yet
            }
            
            // Check if there's an active session (email confirmation may be required)
            // If Supabase requires email confirmation, the session won't exist yet
            if let session = try? await SupabaseManager.shared.client.auth.session {
                supabaseUserId = session.user.id
                currentUser = User(
                    id: userId,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    tier: .silver,
                    loyaltyPoints: 0
                )
                withAnimation(.easeInOut(duration: 0.6)) {
                    isAuthenticated = true
                    isLoading = false
                }
            } else {
                // Email confirmation is required — inform the user
                authError = "Please check your email and confirm your account, then sign in."
                isLoading = false
            }
        } catch {
            print("[Auth] Sign-up error: \(error)")
            authError = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        isLoading = true
        authError = nil
        
        do {
            let session = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            
            supabaseUserId = session.user.id
            
            // Fetch existing profile — using SyncManager
            if let profile = try await SyncManager.shared.fetchProfile(userId: session.user.id) {
                currentUser = User(
                    id: profile.id,
                    firstName: profile.first_name,
                    lastName: profile.last_name,
                    email: profile.email,
                    tier: MembershipTier(rawValue: profile.tier) ?? .silver,
                    avatarURL: profile.avatar_url.flatMap { URL(string: $0) },
                    loyaltyPoints: profile.loyalty_points
                )
            } else {
                currentUser = User(
                    id: session.user.id,
                    firstName: "",
                    lastName: "",
                    email: email,
                    tier: .silver
                )
            }
            
            withAnimation(.easeInOut(duration: 0.6)) {
                isAuthenticated = true
                isLoading = false
            }
        } catch {
            print("[Auth] Sign-in error: \(error)")
            authError = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Dev Skip Login (for development only)
    
    func login() {
        // Use a fixed, stable ID for Dev Mode to ensure profile and orders persist correctly
        let fixedDevId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        
        let devProfile = ProfileDTO(
            id: fixedDevId,
            first_name: "Dev",
            last_name: "User",
            email: "dev@dior.com",
            phone: "+919999999999",
            tier: "platinum",
            loyalty_points: 1850,
            avatar_url: nil
        )
        
        currentUser = User(
            id: fixedDevId,
            firstName: "Dev",
            lastName: "User",
            email: "dev@dior.com",
            tier: .platinum,
            loyaltyPoints: 1850
        )
        supabaseUserId = fixedDevId
        
        // Ensure profile exists in DB
        Task {
            do {
                try await SyncManager.shared.upsertProfile(devProfile)
                print("✅ Dev Profile synced to Supabase")
            } catch {
                print("⚠️ Failed to sync dev profile: \(error)")
            }
        }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = true
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async {
        isLoading = true
        authError = nil
        
        do {
            let url = try await SupabaseManager.shared.client.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: URL(string: "dior-customer://auth/callback"),
                queryParams: [(name: "prompt", value: "select_account")]
            )
            
            // Open the URL to trigger the authentication flow in the browser
            if let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene {
                await UIApplication.shared.open(url)
            }
            
            // Loading state will be turned off when the App's .onOpenURL callback triggers handleOAuthCallback
        } catch {
            authError = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Handle OAuth Callback
    
    func handleOAuthCallback(url: URL) async {
        print("[Auth] Handling OAuth Callback URL: \(url.absoluteString)")
        isLoading = true
        do {
            let session = try await SupabaseManager.shared.client.auth.session(from: url)
            supabaseUserId = session.user.id
            
            // Check if profile exists — using SyncManager
            if let profile = try await SyncManager.shared.fetchProfile(userId: session.user.id) {
                currentUser = User(
                    id: profile.id,
                    firstName: profile.first_name,
                    lastName: profile.last_name,
                    email: profile.email,
                    tier: MembershipTier(rawValue: profile.tier) ?? .silver,
                    avatarURL: profile.avatar_url.flatMap { URL(string: $0) },
                    loyaltyPoints: profile.loyalty_points
                )
            } else {
                // Create profile from Google user info
                let email = session.user.email ?? ""
                let metadata = session.user.userMetadata
                let fullName = metadata["full_name"]?.value as? String ?? ""
                let parts = fullName.split(separator: " ", maxSplits: 1)
                let first = parts.first.map(String.init) ?? ""
                let last = parts.count > 1 ? String(parts[1]) : ""
                
                let profile = ProfileDTO(
                    id: session.user.id,
                    first_name: first,
                    last_name: last,
                    email: email,
                    phone: nil,
                    tier: "SILVER",
                    loyalty_points: 0,
                    avatar_url: metadata["avatar_url"]?.value as? String
                )
                try? await SyncManager.shared.upsertProfile(profile)
                
                currentUser = User(
                    id: session.user.id,
                    firstName: first,
                    lastName: last,
                    email: email,
                    tier: .silver
                )
            }
            
            withAnimation(.easeInOut(duration: 0.6)) {
                isAuthenticated = true
                isLoading = false
            }
        } catch {
            authError = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Sign Out
    
    func logout() {
        Task {
            try? await SupabaseManager.shared.client.auth.signOut()
        }
        supabaseUserId = nil
        currentUser = nil
        withAnimation(.easeInOut(duration: 0.6)) {
            isAuthenticated = false
        }
    }
    
    // MARK: - Update Profile
    
    func updateProfile(firstName: String, lastName: String, email: String) {
        currentUser?.firstName = firstName
        currentUser?.lastName = lastName
        currentUser?.email = email
        
        // Sync to Supabase
        guard let userId = supabaseUserId ?? currentUser?.id else { return }
        Task {
            let profile = ProfileDTO(
                id: userId,
                first_name: firstName,
                last_name: lastName,
                email: email,
                phone: nil,
                tier: currentUser?.tier.rawValue ?? "SILVER",
                loyalty_points: 0,
                avatar_url: currentUser?.avatarURL?.absoluteString
            )
            try? await SyncManager.shared.upsertProfile(profile)
        }
    }
    
    // MARK: - Avatar Upload
    
    func uploadAvatar(data: Data) async throws {
        guard let user = currentUser else { return }
        let fileName = "\(user.id.uuidString)/avatar_\(Date().timeIntervalSince1970).jpg"
        
        let client = SupabaseManager.shared.client
        
        // 1. Upload to storage
        try await client.storage
            .from("avatars")
            .upload(
                path: fileName,
                file: data,
                options: .init(contentType: "image/jpeg", upsert: true)
            )
        
        // 2. Get public URL
        let publicURL = try client.storage.from("avatars").getPublicURL(path: fileName)
        
        // 3. Update DB
        try await client.from("customer_profiles")
            .update(["avatar_url": publicURL.absoluteString])
            .eq("id", value: user.id)
            .execute()
        
        // 4. Update local state
        self.currentUser?.avatarURL = publicURL
    }
}
