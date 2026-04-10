//
//  CheckoutPaymentView.swift
//  User-Side-App
//
//  Step 2 of Checkout: Select Payment Method
//

import SwiftUI

struct CheckoutPaymentView: View {
    @Environment(ProfileManager.self) private var profileManager
    
    let selectedAddressId: UUID
    
    @State private var selectedCardId: UUID?
    @State private var selectedMethod: PaymentMethod = .card
    @State private var showAddCardForm = false
    @State private var cardToEdit: PaymentCard? = nil
    
    enum PaymentMethod {
        case card, upi, cod
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Stepper Indicator
                    CheckoutStepper(currentStep: 2)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    Text("Payment Method")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                        .padding(.horizontal, 20)
                    
                    // Saved Cards Section
                    paymentMethodHeader(title: "Credit / Debit Card", method: .card)
                    
                    if selectedMethod == .card {
                        if profileManager.savedCards.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(profileManager.savedCards) { card in
                                    CardSelectionCard(
                                        card: card,
                                        isSelected: selectedCardId == card.id,
                                        onSelect: { selectedCardId = card.id },
                                        onEdit: { cardToEdit = card },
                                        onDelete: { profileManager.deleteCard(id: card.id) }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Button(action: { showAddCardForm = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Card")
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
                    }
                    
                    // Other Methods
                    paymentMethodHeader(title: "UPI", method: .upi)
                    paymentMethodHeader(title: "Cash on Delivery (COD)", method: .cod)
                    
                    Color.clear.frame(height: 100)
                }
            }
            
            // Bottom Bar
            VStack {
                NavigationLink(destination: CheckoutSummaryView(addressId: selectedAddressId, paymentMethod: selectedMethod == .cod ? "Cash on Delivery" : (selectedMethod == .upi ? "UPI" : "Card Ending in \((profileManager.savedCards.first(where: { $0.id == selectedCardId }) ?? profileManager.defaultCard)?.last4 ?? "")"))) {
                    HStack {
                        Text("REVIEW ORDER")
                            .fontWeight(.bold)
                            .tracking(1)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(isSelectionValid ? AppColors.background : AppColors.grayMedium)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(isSelectionValid ? LinearGradient.goldSubtle : LinearGradient(colors: [AppColors.surfaceElevated], startPoint: .top, endPoint: .bottom))
                    .clipShape(Capsule())
                }
                .disabled(!isSelectionValid)
                .buttonStyle(PressButtonStyle())
            }
            .padding(20)
            .background(AppColors.surfaceDark.ignoresSafeArea(edges: .bottom))
        }
        .background(AppColors.background)
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedCardId == nil {
                selectedCardId = profileManager.defaultCard?.id
            }
        }
        .sheet(isPresented: $showAddCardForm) {
            CardFormView(cardToEdit: nil)
        }
        .sheet(item: $cardToEdit) { card in
            CardFormView(cardToEdit: card)
        }
    }
    
    private var isSelectionValid: Bool {
        if selectedMethod == .card {
            return selectedCardId != nil || profileManager.defaultCard != nil
        }
        return true
    }
    
    private func paymentMethodHeader(title: String, method: PaymentMethod) -> some View {
        Button(action: {
            withAnimation { selectedMethod = method }
        }) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(selectedMethod == method ? AppColors.gold : AppColors.grayMedium, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    
                    if selectedMethod == method {
                        Circle()
                            .fill(AppColors.gold)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(selectedMethod == method ? .bold : .medium)
                    .foregroundStyle(selectedMethod == method ? AppColors.pureWhite : AppColors.grayLight)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(selectedMethod == method ? AppColors.surfaceDark : .clear)
        }
        .buttonStyle(.plain)
    }
    
    private var emptyState: some View {
        Text("No saved cards")
            .font(.subheadline)
            .foregroundStyle(AppColors.grayLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
    }
}

// MARK: - Card Selection Card

struct CardSelectionCard: View {
    let card: PaymentCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 16) {
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
                
                // Card Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(card.network.rawValue) ending in \(card.last4)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.pureWhite)
                        
                        if card.isDefault {
                            Text("Default")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.gold)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("Expires \(card.expiryDate)")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                }
                
                Spacer()
                
                // Actions menu
                Menu {
                    Button("Edit") { onEdit() }
                    Button("Delete", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.grayLight)
                        .padding(8)
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
