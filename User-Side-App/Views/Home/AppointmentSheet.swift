//
//  AppointmentSheet.swift
//  User-Side-App
//
//  LUXE Boutique Appointment — Private store visit booking
//

import SwiftUI

struct AppointmentSheet: View {
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var appointmentType: String = "In-Store Styling"
    @State private var appointmentTitle: String = ""
    @State private var note = ""
    @State private var isBooked = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Store Selection
    @State private var availableStores: [StoreDTO] = []
    @State private var selectedStoreId: UUID? = nil
    @State private var showStorePicker = false
    
    private let appointmentTypes = [
        "In-Store Styling",
        "Virtual Consultation",
        "Repair/Service",
        "Collection Preview"
    ]
    
    private var selectedStore: StoreDTO? {
        availableStores.first(where: { $0.id == selectedStoreId })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if isBooked {
                    successView
                } else {
                    bookingForm
                }
            }
            .navigationTitle("BOUTIQUE VISIT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.gold)
                }
            }
            .sheet(isPresented: $showStorePicker) {
                StorePickerSheet(stores: availableStores, selectedId: $selectedStoreId)
                    .presentationDetents([.medium])
            }
            .task {
                await loadStores()
            }
        }
    }
    
    private var bookingForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Intro
                VStack(alignment: .leading, spacing: 8) {
                    Text("Private Experience")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.gold)
                    Text("Book a personal consultation with our boutique experts.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                }
                
                // Boutique Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT BOUTIQUE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    
                    Button(action: { showStorePicker = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if let store = selectedStore {
                                    Text(store.name)
                                        .font(.subheadline).fontWeight(.bold)
                                        .foregroundStyle(AppColors.pureWhite)
                                    Text(store.city)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.gold)
                                } else {
                                    Text("Choose a location")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.grayMedium)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                        }
                        .padding(16)
                        .background(AppColors.surfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                
                // Date Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT DATE & TIME")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .tint(AppColors.gold)
                        .padding(10)
                        .background(AppColors.surfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Type Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("TYPE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    
                    Picker("Appointment Type", selection: $appointmentType) {
                        ForEach(appointmentTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.pureWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Title (Optional)
                VStack(alignment: .leading, spacing: 16) {
                    Text("TITLE (OPTIONAL)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    
                    TextField("e.g., Summer Collection fitting", text: $appointmentTitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.pureWhite)
                        .padding(16)
                        .background(AppColors.surfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 16) {
                    Text("SPECIAL REQUESTS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.grayMedium)
                    
                    TextEditor(text: $note)
                        .frame(height: 100)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(AppColors.surfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Book Button
                Button(action: { 
                    bookAppointment()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(AppColors.background).padding(.trailing, 8)
                        }
                        Text(isLoading ? "BOOKING..." : "CONFIRM APPOINTMENT")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient.goldSubtle.opacity(selectedStoreId == nil || isLoading ? 0.5 : 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading || selectedStoreId == nil)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
                
                Color.clear.frame(height: 40)
            }
            .padding(20)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.gold)
            
            VStack(spacing: 8) {
                Text("BOOKED")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text("APPOINTMENT SECURED")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.gold)
                
                if let store = selectedStore {
                    Text("At \(store.name), \(store.city)")
                        .font(.caption)
                        .foregroundStyle(AppColors.goldLight)
                }
                
                Text("We look forward to welcoming you to our boutique.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .multilineTextAlignment(.center)
            }
            
            Button("Done") { dismiss() }
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.gold)
                .padding(.top, 20)
        }
    }
    
    private func loadStores() async {
        do {
            let fetched = try await SyncManager.shared.fetchStores()
            await MainActor.run {
                self.availableStores = fetched
                // Pre-select first store if none selected
                if self.selectedStoreId == nil {
                    self.selectedStoreId = fetched.first?.id
                }
            }
        } catch {
            print("Failed to load stores: \(error)")
        }
    }
    
    private func bookAppointment() {
        guard let userId = userManager.supabaseUserId else {
            errorMessage = "Please log in to book an appointment."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = formatter.string(from: selectedDate)
            
            // Build DTO
            let dto = AppointmentDTO(
                user_id: userId,
                title: appointmentTitle.isEmpty ? nil : appointmentTitle,
                type: appointmentType,
                appointment_date: dateString,
                notes: note.isEmpty ? nil : note,
                status: "pending",
                store_id: selectedStoreId
            )
            
            // Get profile for VIP sync
            let profile = try? await SyncManager.shared.fetchProfile(userId: userId)
            
            // Call SyncManager
            do {
                try await SyncManager.shared.bookAppointment(dto: dto, profile: profile)
                await MainActor.run {
                    withAnimation {
                        isBooked = true
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to book appointment. Please try again."
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AppointmentSheet()
}
