//
//  AppointmentSheet.swift
//  User-Side-App
//
//  LUXE Boutique Appointment — Private store visit booking
//

import SwiftUI

struct AppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var note = ""
    @State private var isBooked = false
    
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
                    withAnimation { isBooked = true }
                }) {
                    Text("CONFIRM APPOINTMENT")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(LinearGradient.goldSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                Text("APPOINTMENT SECURED")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.pureWhite)
                
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
}

#Preview {
    AppointmentSheet()
}
