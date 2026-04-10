//
//  CheckoutAddressView.swift
//  User-Side-App
//
//  Step 1 of Checkout: Select or Manage Address
//

import SwiftUI

struct CheckoutAddressView: View {
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var selectedAddressId: UUID?
    @State private var showAddForm = false
    @State private var addressToEdit: Address? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Stepper Indicator
                    CheckoutStepper(currentStep: 1)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    Text("Select Delivery Address")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                        .padding(.horizontal, 20)
                    
                    if profileManager.addresses.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(profileManager.addresses) { address in
                                AddressSelectionCard(
                                    address: address,
                                    isSelected: selectedAddressId == address.id,
                                    onSelect: { selectedAddressId = address.id },
                                    onEdit: { addressToEdit = address },
                                    onDelete: { profileManager.deleteAddress(id: address.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Button(action: { showAddForm = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Address")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundStyle(AppColors.gold.opacity(0.5))
                        )
                    }
                    .buttonStyle(PressButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Color.clear.frame(height: 100)
                }
            }
            
            // Bottom Bar
            if !profileManager.addresses.isEmpty {
                VStack {
                    NavigationLink(destination: CheckoutPaymentView(selectedAddressId: selectedAddressId ?? profileManager.defaultAddress?.id ?? UUID())) {
                        HStack {
                            Text("CONTINUE TO PAYMENT")
                                .fontWeight(.bold)
                                .tracking(1)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(selectedAddressId != nil || profileManager.defaultAddress != nil ? AppColors.background : AppColors.grayMedium)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(selectedAddressId != nil || profileManager.defaultAddress != nil ? LinearGradient.goldSubtle : LinearGradient(colors: [AppColors.surfaceElevated], startPoint: .top, endPoint: .bottom))
                        .clipShape(Capsule())
                    }
                    .disabled(selectedAddressId == nil && profileManager.defaultAddress == nil)
                    .buttonStyle(PressButtonStyle())
                }
                .padding(20)
                .background(AppColors.surfaceDark.ignoresSafeArea(edges: .bottom))
            }
        }
        .background(AppColors.background)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedAddressId == nil {
                selectedAddressId = profileManager.defaultAddress?.id
            }
        }
        .sheet(isPresented: $showAddForm) {
            AddressFormView(addressToEdit: nil)
        }
        .sheet(item: $addressToEdit) { address in
            AddressFormView(addressToEdit: address)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "house")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.grayMedium)
            
            Text("No saved addresses")
                .font(.subheadline)
                .foregroundStyle(AppColors.grayLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Address Selection Card

struct AddressSelectionCard: View {
    let address: Address
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 16) {
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.gold : AppColors.grayMedium, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.gold)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 4)
                
                // Address Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(address.name)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.pureWhite)
                        
                        if address.isDefault {
                            Text("Default")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.gold)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    
                    Text("\(address.street)\n\(address.city), \(address.state) \(address.zipCode)\nPhone: \(address.phoneNumber)")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                    
                    // Actions
                    HStack(spacing: 16) {
                        Button("Edit", action: onEdit)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.gold)
                        
                        Button("Delete") { onDelete() }
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(16)
            .darkCard()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.gold : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Checkout Stepper UI

struct CheckoutStepper: View {
    let currentStep: Int // 1=Address, 2=Payment, 3=Review
    
    var body: some View {
        HStack {
            stepView(number: 1, title: "Address", isActive: currentStep >= 1)
            line(isActive: currentStep >= 2)
            stepView(number: 2, title: "Payment", isActive: currentStep >= 2)
            line(isActive: currentStep >= 3)
            stepView(number: 3, title: "Review", isActive: currentStep >= 3)
        }
    }
    
    private func stepView(number: Int, title: String, isActive: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? AppColors.gold : AppColors.surfaceElevated)
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(isActive ? AppColors.background : AppColors.grayLight)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isActive ? AppColors.pureWhite : AppColors.grayLight)
        }
    }
    
    private func line(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? AppColors.gold : AppColors.surfaceElevated)
            .frame(height: 2)
            .padding(.horizontal, 4)
            .offset(y: -10)
    }
}
