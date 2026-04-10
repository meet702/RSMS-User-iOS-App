//
//  CardFormView.swift
//  User-Side-App
//
//  Modal form to add or edit a payment card
//

import SwiftUI

struct CardFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileManager.self) private var profileManager
    
    var cardToEdit: PaymentCard?
    
    // Form State
    @State private var cardholderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var isDefault: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Card Information") {
                    TextField("Name on Card", text: $cardholderName)
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        TextField("MM/YY", text: $expiryDate)
                        Divider()
                        SecureField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section {
                    Toggle("Save as Default Card", isOn: $isDefault)
                        .tint(AppColors.gold)
                }
            }
            .navigationTitle(cardToEdit == nil ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.grayLight)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCard() }
                        .fontWeight(.bold)
                        .foregroundStyle(isFormValid ? AppColors.gold : AppColors.grayDark)
                        .disabled(!isFormValid)
                }
            }
            .onAppear {
                if let card = cardToEdit {
                    cardholderName = card.cardholderName
                    cardNumber = card.cardNumber
                    expiryDate = card.expiryDate
                    cvv = card.cvv
                    isDefault = card.isDefault
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var isFormValid: Bool {
        !cardholderName.isEmpty && cardNumber.count >= 15 && !expiryDate.isEmpty && cvv.count >= 3
    }
    
    private func saveCard() {
        let newCard = PaymentCard(
            id: cardToEdit?.id ?? UUID(),
            cardholderName: cardholderName,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            isDefault: isDefault
        )
        
        if cardToEdit != nil {
            profileManager.updateCard(newCard)
        } else {
            profileManager.addCard(newCard)
        }
        
        dismiss()
    }
}
