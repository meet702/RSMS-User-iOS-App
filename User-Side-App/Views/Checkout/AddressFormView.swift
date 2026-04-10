//
//  AddressFormView.swift
//  User-Side-App
//
//  Modal form to add or edit an address
//

import SwiftUI

struct AddressFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileManager.self) private var profileManager
    
    var addressToEdit: Address?
    
    // Form State
    @State private var name: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var phoneNumber: String = ""
    @State private var isDefault: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Full Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Address Details") {
                    TextField("Street / Apartment / building", text: $street)
                    TextField("City", text: $city)
                    HStack {
                        TextField("State", text: $state)
                        Divider()
                        TextField("ZIP/PIN Code", text: $zipCode)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section {
                    Toggle("Save as Default Address", isOn: $isDefault)
                        .tint(AppColors.gold)
                }
            }
            .navigationTitle(addressToEdit == nil ? "New Address" : "Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.grayLight)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAddress() }
                        .fontWeight(.bold)
                        .foregroundStyle(isFormValid ? AppColors.gold : AppColors.grayDark)
                        .disabled(!isFormValid)
                }
            }
            .onAppear {
                if let address = addressToEdit {
                    name = address.name
                    street = address.street
                    city = address.city
                    state = address.state
                    zipCode = address.zipCode
                    phoneNumber = address.phoneNumber
                    isDefault = address.isDefault
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && !phoneNumber.isEmpty
    }
    
    private func saveAddress() {
        let newAddress = Address(
            id: addressToEdit?.id ?? UUID(),
            name: name,
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            phoneNumber: phoneNumber,
            isDefault: isDefault
        )
        
        if addressToEdit != nil {
            profileManager.updateAddress(newAddress)
        } else {
            profileManager.addAddress(newAddress)
        }
        
        dismiss()
    }
}
