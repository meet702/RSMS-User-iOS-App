//
//  CheckoutView.swift
//  User-Side-App
//
//  LUXE Checkout experience — Address, Payment, Summary
//  Address and Payment cards are now interactive pickers.
//

import SwiftUI
import Supabase

struct CheckoutView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(OrdersManager.self) private var ordersManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showAddressPicker = false
    @State private var showPaymentPicker = false
    @State private var isPlacingOrder = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var failedOrderItems: [CartItem] = []
    @State private var userAddresses: [AddressDTO] = []
    
    // Offers
    @State private var availableOffers: [OfferDTO] = []
    @State private var selectedOffer: OfferDTO? = nil
    
    var offerDiscount: Double {
        guard let offer = selectedOffer else { return 0.0 }
        if offer.discount_type == "percentage" {
            let discount = cartManager.subtotal * (offer.discount_value / 100.0)
            return min(discount, cartManager.subtotal)
        } else {
            return min(offer.discount_value, cartManager.subtotal)
        }
    }
    
    var finalTotal: Double {
        let total = cartManager.subtotal - offerDiscount
        return max(1.0, total) // Prevent Razorpay crash on <= 0 payments
    }
    
    // Razorpay success handling
    @State private var paymentId: String? = nil
    
    // Address options — Now fetched or entered dynamically
    private var addresses: [String] {
        let saved = userAddresses.map { $0.full_address }
        return saved + ["Add New Address..."]
    }
    
    // Simulated payment options (Simplified for Real flow)
    private let payments = ["Razorpay (UPI, Card, Wallet)", "Apple Pay"]
    
    @State private var selectedAddressId: UUID? = nil
    @State private var selectedPayment = "Razorpay (UPI, Card, Wallet)"
    @State private var showAddressEntry = false
    
    var currentAddress: AddressDTO? {
        userAddresses.first { $0.id == selectedAddressId }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        checkoutSection(title: "SHIPPING ADDRESS") {
                            addressCard
                        }
                        
                        checkoutSection(title: "PAYMENT METHOD") {
                            paymentCard
                        }
                        
                        checkoutSection(title: "ORDER SUMMARY") {
                            orderSummaryCard
                        }
                        
                        if !availableOffers.isEmpty {
                            checkoutSection(title: "AVAILABLE OFFERS") {
                                offersCard
                            }
                        }
                        
                        Color.clear.frame(height: 120)
                    }
                    .padding(20)
                }
                
                placeOrderFooter
            }
            .navigationTitle("CHECKOUT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(AppColors.grayLight)
                }
                ToolbarItem(placement: .principal) {
                    Text("CHECKOUT").font(.headline).fontWeight(.bold).tracking(4).foregroundStyle(AppColors.gold)
                }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                OrderSuccessView(onComplete: { dismiss() })
            }
            // Address picker sheet
            .sheet(isPresented: $showAddressPicker) {
                AddressPickerSheet(
                    addresses: userAddresses,
                    selectedId: $selectedAddressId,
                    onAddNew: {
                        showAddressPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showAddressEntry = true
                        }
                    },
                    onRefresh: {
                        Task { await loadUserAddresses() }
                    }
                )
                .presentationDetents([.medium])
            }
            // Add NEW Address Entry Sheet (Map Based)
            .sheet(isPresented: $showAddressEntry) {
                MapAddressPickerView(onSave: { structured in
                    saveNewAddress(structured)
                    showAddressEntry = false
                })
            }
            // Payment picker sheet
            .sheet(isPresented: $showPaymentPicker) {
                SimplePickerSheet(
                    title: "SELECT PAYMENT",
                    options: payments,
                    selected: $selectedPayment
                )
                .presentationDetents([.medium])
            }
            .alert("PAYMENT ERROR", isPresented: $showError) {
                if errorMessage.contains("network") || errorMessage.contains("connection") {
                    Button("Retry Saving Order") {
                        retryOrderRecording()
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadUserAddresses()
                await loadOffers()
            }
        }
    }
    
    // MARK: - API
    
    private func loadUserAddresses() async {
        guard let userId = userManager.supabaseUserId else { return }
        do {
            let fetched = try await SyncManager.shared.fetchAddresses(userId: userId)
            
            await MainActor.run {
                self.userAddresses = fetched
                
                // If nothing selected, or current selection is gone, pick default
                if selectedAddressId == nil || !userAddresses.contains(where: { $0.id == selectedAddressId }) {
                    if let defaultAddr = userAddresses.first(where: { $0.is_default }) {
                        selectedAddressId = defaultAddr.id
                    } else if let first = userAddresses.first {
                        selectedAddressId = first.id
                    }
                }
            }
        } catch {
            print("Failed to load addresses: \(error)")
        }
    }
    
    private func loadOffers() async {
        do {
            let offers = try await SyncManager.shared.fetchActiveOffers()
            await MainActor.run {
                // Ensure the list is filtered to fully active within date range if needed,
                // but relying on "status == 'active'" from remote is fine for now
                self.availableOffers = offers
            }
        } catch {
            print("Failed to load offers: \(error)")
        }
    }
    
    private func saveNewAddress(_ structured: StructuredAddress) {
        guard let userId = userManager.supabaseUserId else { return }
        
        Task {
            let newId = UUID()
            let newDTO = AddressDTO(
                id: newId,
                user_id: userId,
                label: "Home",
                building_name: structured.buildingName,
                area_street: structured.areaStreet,
                landmark: structured.landmark,
                city: structured.city,
                state: structured.state,
                pincode: structured.pincode,
                country: structured.country,
                full_address: structured.fullAddress,
                is_default: userAddresses.isEmpty,
                created_at: nil
            )
            
            do {
                try await SyncManager.shared.addAddress(address: newDTO)
                await loadUserAddresses()
                await MainActor.run {
                    self.selectedAddressId = newId
                }
            } catch {
                print("Failed to save address: \(error)")
            }
        }
    }
    
    // MARK: - Components
    
    private func checkoutSection<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.system(size: 11, weight: .bold)).tracking(2).foregroundStyle(AppColors.grayMedium)
            content()
        }
    }
    
    private var addressCard: some View {
        Button(action: { showAddressPicker = true }) {
            HStack(spacing: 16) {
                Image(systemName: "mappin.circle.fill").font(.title2).foregroundStyle(AppColors.gold)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let addr = currentAddress {
                        Text(addr.building_name ?? "Selected Location")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(AppColors.pureWhite)
                        Text("\(addr.area_street ?? ""), \(addr.city)")
                            .font(.caption)
                            .foregroundStyle(AppColors.grayLight)
                    } else {
                        Text("Select Shipping Address")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(AppColors.grayMedium)
                    }
                    Text("Standard Delivery: 3–5 Business Days")
                        .font(.caption2).foregroundStyle(AppColors.gold.opacity(0.8)).padding(.top, 2)
                }
                
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppColors.gold)
            }
            .padding(16).darkCard(goldBorder: true)
        }
        .buttonStyle(.plain)
    }
    
    private var paymentCard: some View {
        Button(action: { showPaymentPicker = true }) {
            HStack(spacing: 16) {
                Image(systemName: "creditcard.fill").font(.title2).foregroundStyle(AppColors.gold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedPayment).font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(AppColors.pureWhite)
                    Text(cartManager.subtotal.formattedPrice).font(.caption2).foregroundStyle(AppColors.grayLight)
                }
                
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppColors.gold)
            }
            .padding(16).darkCard(goldBorder: true)
        }
        .buttonStyle(.plain)
    }
    
    private var orderSummaryCard: some View {
        VStack(spacing: 12) {
            ForEach(cartManager.items.prefix(3)) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .font(.caption).foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(item.totalPrice.formattedPrice)
                        .font(.caption).foregroundStyle(AppColors.pureWhite)
                }
            }
            
            if cartManager.items.count > 3 {
                Text("+ \(cartManager.items.count - 3) more items")
                    .font(.caption2).foregroundStyle(AppColors.gold).frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            HStack {
                Text("SUBTOTAL").font(.caption).foregroundStyle(AppColors.grayLight)
                Spacer()
                Text(cartManager.subtotal.formattedPrice).font(.caption).foregroundStyle(AppColors.pureWhite)
            }
            
            if offerDiscount > 0 {
                HStack {
                    Text(selectedOffer?.name.uppercased() ?? "OFFER").font(.caption).foregroundStyle(AppColors.gold)
                    Spacer()
                    Text("-\(offerDiscount.formattedPrice)").font(.caption).foregroundStyle(AppColors.gold)
                }
            }
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            HStack {
                Text("TOTAL AMOUNT").font(.subheadline).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                Spacer()
                Text(finalTotal.formattedPrice).font(.headline).fontWeight(.bold).foregroundStyle(AppColors.gold)
            }
        }
        .padding(16).darkCard(goldBorder: false)
    }
    
    private var offersCard: some View {
        VStack(spacing: 12) {
            ForEach(availableOffers) { offer in
                Button(action: {
                    withAnimation {
                        if selectedOffer?.id == offer.id {
                            selectedOffer = nil // Deselect
                        } else {
                            selectedOffer = offer
                        }
                    }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: selectedOffer?.id == offer.id ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(selectedOffer?.id == offer.id ? AppColors.gold : AppColors.grayDark)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(offer.name)
                                .font(.subheadline).fontWeight(.bold)
                                .foregroundStyle(selectedOffer?.id == offer.id ? AppColors.gold : AppColors.pureWhite)
                            
                            if let code = offer.coupon_code {
                                Text("Code: \(code)").font(.caption2).foregroundStyle(AppColors.grayLight)
                            }
                        }
                        
                        Spacer()
                        
                        if offer.discount_type == "percentage" {
                            Text("\(Int(offer.discount_value))% OFF")
                                .font(.caption).fontWeight(.bold)
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(AppColors.gold)
                                .clipShape(Capsule())
                        } else {
                            Text(offer.discount_value.formattedPrice + " OFF")
                                .font(.caption).fontWeight(.bold)
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(AppColors.gold)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedOffer?.id == offer.id ? AppColors.gold : AppColors.grayDark.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var placeOrderFooter: some View {
        VStack {
            Button(action: { placeOrder() }) {
                HStack(spacing: 12) {
                    if isPlacingOrder {
                        ProgressView().progressViewStyle(.circular).tint(AppColors.background)
                    } else {
                        Text("PLACE ORDER")
                        Image(systemName: "arrow.right")
                    }
                }
                .font(.subheadline).fontWeight(.bold).tracking(2)
                .foregroundStyle(AppColors.background)
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(LinearGradient.goldSubtle.opacity(isPlacingOrder || userManager.isLoading || selectedAddressId == nil ? 0.5 : 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressButtonStyle())
            .disabled(isPlacingOrder || userManager.isLoading || selectedAddressId == nil)
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 34)
            .background(AppColors.background.shadow(color: .black.opacity(0.4), radius: 10, y: -5))
        }
    }
    
    // MARK: - Actions
    
    private func placeOrder() {
        guard let userId = userManager.supabaseUserId,
              let email = userManager.currentUser?.email else { return }
        
        // If not using Razorpay, just simulate success for now
        if !selectedPayment.contains("Razorpay") {
            withAnimation {
                isPlacingOrder = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccess = true
                    isPlacingOrder = false
                }
            }
            return
        }
        
        withAnimation { isPlacingOrder = true }
        
        Task {
            do {
                // 1. Create Razorpay Order via Edge Function
                let orderId = try await ordersManager.fetchRazorpayOrderID(amount: finalTotal)
                
                // 2. Open Razorpay Checkout
                RazorpayManager.shared.startPayment(
                    orderId: orderId,
                    amount: finalTotal,
                    email: email,
                    contact: "9999999999", // Should be fetched from profile
                    onSuccess: { paymentId in
                        self.paymentId = paymentId
                        self.handlePaymentSuccess()
                    },
                    onFailure: { error in
                        print("Razorpay failed: \(error)")
                        self.errorMessage = error
                        self.showError = true
                        isPlacingOrder = false
                    }
                )
            } catch {
                print("Failed to prepare Razorpay: \(error)")
                
                // Try to extract a more descriptive error from Supabase
                var detailedMessage = error.localizedDescription
                
                if let functionsError = error as? FunctionsError {
                    switch functionsError {
                    case .httpError(let status, let data):
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = json["error"] as? String {
                            detailedMessage = "Edge Function Error (\(status)): \(message)"
                        } else if let bodyString = String(data: data, encoding: .utf8) {
                            detailedMessage = "Edge Function Error (\(status)): \(bodyString)"
                        }
                    case .relayError:
                        detailedMessage = "Network Relay Error: The Edge Function could not be reached."
                    default:
                        break
                    }
                }
                
                self.errorMessage = detailedMessage
                self.showError = true
                isPlacingOrder = false
            }
        }
    }
    
    private func handlePaymentSuccess() {
        // DEBUG: Confirm this is only called after a successful Razorpay payment
        print("✅ handlePaymentSuccess invoked – proceeding to record order in Supabase")
        guard let userId = userManager.supabaseUserId else { return }
        
        // 1. Capture items BEFORE clearing cart
        let itemsToOrder = cartManager.items
        self.failedOrderItems = itemsToOrder // Store in case we need to retry
        
        // 2. Clear cart INSTANTLY so user sees their bag is empty
        cartManager.clearCart(userId: userId)
        
        // 3. Record the order in our database in the background
        Task {
            let addressText = currentAddress?.full_address ?? "Unknown Address"
            await performOrderRecording(items: itemsToOrder, userId: userId, shippingAddress: addressText)
        }
    }
    
    private func performOrderRecording(items: [CartItem], userId: UUID, shippingAddress: String) async {
        isPlacingOrder = true
        do {
            try await ordersManager.placeOrder(
                from: items, 
                userId: userId, 
                redeemedPoints: 0,
                offerDiscount: offerDiscount,
                shippingAddress: shippingAddress,
                paymentMethod: selectedPayment
            )
            showSuccess = true
            failedOrderItems = []
        } catch {
            print("Order recording failed: \(error)")
            self.errorMessage = "DATABASE ERROR: \(error.localizedDescription)\n\nPlease contact support if the issue persists."
            self.showError = true
        }
        isPlacingOrder = false
    }
    
    private func retryOrderRecording() {
        guard let userId = userManager.supabaseUserId else { return }
        let addressText = currentAddress?.full_address ?? "Unknown Address"
        Task {
            await performOrderRecording(items: failedOrderItems, userId: userId, shippingAddress: addressText)
        }
    }

}

// MARK: - Picker Sheets

struct AddressPickerSheet: View {
    let addresses: [AddressDTO]
    @Binding var selectedId: UUID?
    let onAddNew: () -> Void
    let onRefresh: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Saved Addresses
                    ForEach(addresses) { address in
                        Button(action: {
                            selectedId = address.id
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: selectedId == address.id ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedId == address.id ? AppColors.gold : AppColors.grayDark)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(address.building_name ?? "No Name")
                                        .font(.subheadline).fontWeight(.bold)
                                        .foregroundStyle(AppColors.pureWhite)
                                    Text("\(address.area_street ?? ""), \(address.city)")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.grayLight)
                                    if let label = address.label {
                                        Text(label.uppercased()).font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(AppColors.gold).padding(.top, 2)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20).padding(.vertical, 18)
                        }
                        .buttonStyle(.plain)
                        Divider().background(AppColors.grayDark.opacity(0.3)).padding(.horizontal, 20)
                    }
                    
                    // Add New
                    Button(action: onAddNew) {
                        HStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.gold)
                            Text("Add New Address...")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.gold)
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.vertical, 18)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle("SELECT ADDRESS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise").foregroundStyle(AppColors.gold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct SimplePickerSheet: View {
    let title: String
    let options: [String]
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selected = option
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: selected == option ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selected == option ? AppColors.gold : AppColors.grayDark)
                                Text(option).font(.subheadline).foregroundStyle(AppColors.pureWhite)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal, 20).padding(.vertical, 18)
                        }
                        .buttonStyle(.plain)
                        
                        if option != options.last {
                            Divider().background(AppColors.grayDark.opacity(0.3)).padding(.horizontal, 20)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    CheckoutView()
        .withLuxePreviewEnvironment()
}

