//
//  LoginView.swift
//  User-Side-App
//
//  LUXE Login Experience — Gold-on-Black entry screen
//

import SwiftUI

struct LoginView: View {
    @Environment(UserManager.self) private var userManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative background elements
            decorativeBackground
            
            VStack(spacing: 40) {
                Spacer()
                
                // Header / Branding
                headerView
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                
                // Form
                VStack(spacing: 20) {
                    customTextField(placeholder: "Email Address", text: $email, icon: "envelope")
                    customSecureField(placeholder: "Password", text: $password, icon: "lock")
                    
                    HStack {
                        Spacer()
                        Button("Forgot Password?") { }
                            .font(.caption)
                            .foregroundStyle(AppColors.gold)
                    }
                    .padding(.top, -8)
                }
                .padding(.horizontal, 30)
                .offset(y: animateContent ? 0 : 20)
                .opacity(animateContent ? 1 : 0)
                
                // Sign In Button
                Button(action: { handleLogin() }) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(AppColors.background)
                        } else {
                            Text("SIGN IN")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .tracking(3)
                        }
                    }
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient.goldShimmer)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal, 30)
                .offset(y: animateContent ? 0 : 40)
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                
                // Footer
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(AppColors.grayLight)
                    Button("Join LUXE") { }
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.gold)
                }
                .font(.caption)
                .padding(.bottom, 20)
                .opacity(animateContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("LUXE")
                .font(.system(size: 60, weight: .ultraLight))
                .tracking(20)
                .foregroundStyle(LinearGradient.goldSubtle)
            
            Text("RETAIL MANAGEMENT")
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(8)
                .foregroundStyle(AppColors.grayLight)
            
            Rectangle()
                .fill(AppColors.gold.opacity(0.3))
                .frame(width: 40, height: 1)
                .padding(.top, 10)
        }
    }
    
    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(AppColors.gold.opacity(0.03))
                .frame(width: 300)
                .blur(radius: 50)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(AppColors.gold.opacity(0.04))
                .frame(width: 400)
                .blur(radius: 60)
                .offset(x: 180, y: 250)
        }
    }
    
    private func customTextField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.gold.opacity(0.7))
                .frame(width: 20)
            
            TextField("", text: text, prompt: 
                Text(placeholder).foregroundStyle(AppColors.grayMedium)
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.pureWhite)
            .autocapitalization(.none)
        }
        .padding(18)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func customSecureField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.gold.opacity(0.7))
                .frame(width: 20)
            
            SecureField("", text: text, prompt: 
                Text(placeholder).foregroundStyle(AppColors.grayMedium)
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.pureWhite)
        }
        .padding(18)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Actions
    
    private func handleLogin() {
        isLoading = true
        // Simulate network delay
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            userManager.login()
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environment(UserManager())
}
