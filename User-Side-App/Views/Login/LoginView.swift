//
//  LoginView.swift
//  User-Side-App
//
//  DIOR Login Experience — Gold-on-Black entry with Supabase Auth
//

import SwiftUI

struct LoginView: View {
    @Environment(UserManager.self) private var userManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var animateContent = false
    @State private var showSignUp = false
    
    // Sign-up fields
    @State private var signUpFirstName = ""
    @State private var signUpLastName = ""
    @State private var signUpEmail = ""
    @State private var signUpPassword = ""
    
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
                        Button("Forgot Password?") {
                            if email.isEmpty {
                                userManager.authError = "Please enter your email first"
                            } else {
                                Task {
                                    do {
                                        try await userManager.resetPassword(email: email)
                                        userManager.authError = "Check your email for reset instructions"
                                    } catch {
                                        // Error handled by UserManager
                                    }
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(AppColors.gold)
                    }
                    .padding(.top, -8)
                }
                .padding(.horizontal, 30)
                .offset(y: animateContent ? 0 : 20)
                .opacity(animateContent ? 1 : 0)
                
                // Error message
                if let error = userManager.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, -20)
                }
                
                // Sign In Button
                Button(action: { handleLogin() }) {
                    ZStack {
                        if userManager.isLoading {
                            ProgressView()
                                .tint(AppColors.alwaysBlack)
                        } else {
                            Text("SIGN IN")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .tracking(3)
                        }
                    }
                    .foregroundStyle(AppColors.alwaysBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient.goldShimmer)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(userManager.isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal, 30)
                .offset(y: animateContent ? 0 : 40)
                .opacity(animateContent ? 1 : 0)
                
                // OR Divider
                HStack(spacing: 16) {
                    Rectangle().fill(AppColors.grayDark.opacity(0.5)).frame(height: 1)
                    Text("OR")
                        .font(.caption2).fontWeight(.bold).tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    Rectangle().fill(AppColors.grayDark.opacity(0.5)).frame(height: 1)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, -12)
                .opacity(animateContent ? 1 : 0)
                
                // Continue with Google
                Button(action: {
                    Task { await userManager.signInWithGoogle() }
                }) {
                    HStack(spacing: 12) {
                        // Google "G" logo
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 22, height: 22)
                            Text("G")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .yellow, .green, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Continue with Google")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(AppColors.pureWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1)
                    )
                }
                .disabled(userManager.isLoading)
                .padding(.horizontal, 30)
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                
                // Footer
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(AppColors.grayLight)
                    Button("Join DIOR") { showSignUp = true }
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
        .sheet(isPresented: $showSignUp) {
            signUpSheet
        }
    }
    
    // MARK: - Sign Up Sheet
    
    private var signUpSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("DIOR")
                            .font(.system(size: 36, weight: .ultraLight))
                            .tracking(12)
                            .foregroundStyle(LinearGradient.goldSubtle)
                            .padding(.top, 20)
                        
                        Text("Create your account")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.grayLight)
                        
                        VStack(spacing: 16) {
                            customTextField(placeholder: "First Name", text: $signUpFirstName, icon: "person")
                            customTextField(placeholder: "Last Name", text: $signUpLastName, icon: "person")
                            customTextField(placeholder: "Email Address", text: $signUpEmail, icon: "envelope")
                            customSecureField(placeholder: "Password (min 6 chars)", text: $signUpPassword, icon: "lock")
                        }
                        .padding(.horizontal, 6)
                        
                        if let error = userManager.authError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { handleSignUp() }) {
                            ZStack {
                                if userManager.isLoading {
                                    ProgressView().tint(AppColors.alwaysBlack)
                                } else {
                                    Text("CREATE ACCOUNT")
                                        .font(.subheadline).fontWeight(.bold).tracking(3)
                                }
                            }
                            .foregroundStyle(AppColors.alwaysBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(LinearGradient.goldShimmer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(userManager.isLoading || signUpFirstName.isEmpty || signUpLastName.isEmpty || signUpEmail.isEmpty || signUpPassword.count < 6)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showSignUp = false }
                        .foregroundStyle(AppColors.grayLight)
                }
                ToolbarItem(placement: .principal) {
                    Text("JOIN DIOR")
                        .font(.headline).fontWeight(.bold).tracking(4).foregroundStyle(AppColors.gold)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("DIOR")
                .font(.system(size: 60, weight: .ultraLight))
                .tracking(20)
                .foregroundStyle(LinearGradient.goldSubtle)
            
            Text("MAISON DE COUTURE")
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
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
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
        Task {
            await userManager.signIn(email: email, password: password)
        }
    }
    
    private func handleSignUp() {
        Task {
            await userManager.signUp(
                email: signUpEmail,
                password: signUpPassword,
                firstName: signUpFirstName,
                lastName: signUpLastName
            )
            if userManager.isAuthenticated {
                showSignUp = false
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(UserManager())
}
