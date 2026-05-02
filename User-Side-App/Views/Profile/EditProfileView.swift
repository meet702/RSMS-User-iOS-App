//
//  EditProfileView.swift
//  User-Side-App
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(OrdersManager.self) private var ordersManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var isSaving: Bool = false
    @State private var showSuccess: Bool = false
    @State private var fieldFocus: Field? = nil
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var rawAvatarData: Data?
    
    enum Field: Hashable { case firstName, lastName, email, phone }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        avatarSection
                        formSection
                        Color.clear.frame(height: 40)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("EDIT PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.grayLight)
                }
                ToolbarItem(placement: .principal) {
                    Text("EDIT PROFILE")
                        .font(.headline).fontWeight(.bold).tracking(4).foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView().progressViewStyle(.circular).tint(AppColors.gold)
                        } else {
                            Text("SAVE")
                                .font(.subheadline).fontWeight(.bold).foregroundStyle(AppColors.gold)
                        }
                    }
                    .disabled(isSaving || !hasChanges)
                }
            }
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { populateFields() }
            .overlay(successToast)
        }
    }
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        VStack(spacing: 20) {
            PhotosPicker(selection: $avatarItem, matching: .images, photoLibrary: .shared()) {
                ZStack {
                    if let avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if let url = userManager.currentUser?.avatarURL {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView().tint(AppColors.gold)
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(LinearGradient.goldSubtle)
                            .frame(width: 100, height: 100)
                        
                        Text(initials)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                    }
                    
                    Circle()
                        .stroke(AppColors.gold.opacity(0.4), lineWidth: 3)
                        .frame(width: 108, height: 108)
                    
                    ZStack {
                        Circle().fill(AppColors.surfaceDark).frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14)).foregroundStyle(AppColors.gold)
                    }
                    .offset(x: 35, y: 35)
                }
            }
            .buttonStyle(.plain)
            .onChange(of: avatarItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                           if let compressed = uiImage.jpegData(compressionQuality: 0.3) {
                               self.rawAvatarData = compressed
                               self.avatarImage = Image(uiImage: UIImage(data: compressed)!)
                           }
                    }
                }
            }
            
            Text("Tap to change picture")
                .font(.caption2).fontWeight(.bold).tracking(1)
                .foregroundStyle(AppColors.grayMedium)
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 20) {
            sectionLabel("PERSONAL INFORMATION")
            
            VStack(spacing: 1) {
                formRow(icon: "person.fill", label: "First Name", placeholder: "First name", text: $firstName, field: .firstName)
                Divider().background(AppColors.grayDark.opacity(0.4)).padding(.horizontal, 16)
                formRow(icon: "person.fill", label: "Last Name",  placeholder: "Last name",  text: $lastName,  field: .lastName)
            }
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
            
            sectionLabel("CONTACT INFORMATION")
            
            VStack(spacing: 1) {
                formRow(icon: "envelope.fill", label: "Email",  placeholder: "Email address",  text: $email, field: .email, keyboard: .emailAddress)
                Divider().background(AppColors.grayDark.opacity(0.4)).padding(.horizontal, 16)
                formRow(icon: "phone.fill",    label: "Phone",  placeholder: "+91 XXXXX XXXXX", text: $phone, field: .phone, keyboard: .phonePad)
            }
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
        }
    }
    
    private func formRow(icon: String, label: String, placeholder: String,
                         text: Binding<String>, field: Field,
                         keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15)).foregroundStyle(AppColors.gold.opacity(0.8)).frame(width: 20)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(.caption2).tracking(1).foregroundStyle(AppColors.grayMedium)
                TextField(placeholder, text: text)
                    .font(.subheadline).foregroundStyle(AppColors.pureWhite)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
            }
            
            Spacer()
            
            if !text.wrappedValue.isEmpty {
                Button(action: { text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14)).foregroundStyle(AppColors.grayDark)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
    
    // MARK: - Helpers
    
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption2).fontWeight(.bold).tracking(2)
            .foregroundStyle(AppColors.grayMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return f.isEmpty && l.isEmpty ? "??" : "\(f)\(l)"
    }
    
    private var hasChanges: Bool {
        guard let user = userManager.currentUser else { return false }
        return firstName != user.firstName
            || lastName  != user.lastName
            || email     != user.email
            || rawAvatarData != nil
    }
    
    private func populateFields() {
        guard let user = userManager.currentUser else { return }
        firstName = user.firstName
        lastName  = user.lastName
        email     = user.email
        phone     = ""
    }
    
    private func saveProfile() {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation { isSaving = true }
        
        Task {
            if let data = rawAvatarData {
                try? await userManager.uploadAvatar(data: data)
            }
            
            userManager.updateProfile(firstName: firstName.trimmingCharacters(in: .whitespaces),
                                      lastName: lastName.trimmingCharacters(in: .whitespaces),
                                      email: email.trimmingCharacters(in: .whitespaces))
            
            withAnimation(.spring(response: 0.4)) { isSaving = false; showSuccess = true }
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation { dismiss() }
        }
    }
    
    // MARK: - Success Toast
    
    @ViewBuilder
    private var successToast: some View {
        if showSuccess {
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 16))
                    Text("Profile Updated").font(.subheadline).fontWeight(.semibold)
                }
                .foregroundStyle(AppColors.background)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(AppColors.gold).clipShape(Capsule())
                .shadow(color: AppColors.gold.opacity(0.4), radius: 12, y: 4)
                .padding(.top, 60)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    EditProfileView()
        .withLuxePreviewEnvironment()
}
