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
    @State private var completedPurchaseItems: [CartItem] = []
    @State private var userAddresses: [AddressDTO] = []
    @State private var availableStores: [StoreDTO] = []
    @State private var selectedStoreId: UUID? = nil
    @State private var showStorePicker = false
    
    @State private var regionTaxRules: [TaxRuleDTO] = []
    
    // Direct Purchase Bypass
    var directPurchaseItem: CartItem? = nil
    
    private var itemsToCheckout: [CartItem] {
        if let direct = directPurchaseItem {
            return [direct]
        }
        return cartManager.items
    }
    
    private var subtotalToCheckout: Double {
        if let direct = directPurchaseItem {
            return direct.totalPrice
        }
        return cartManager.subtotal
    }
    
    // Offers
    @State private var availableOffers: [OfferDTO] = []
    @State private var selectedOffer: OfferDTO? = nil
    
    var offerDiscount: Double {
        guard let offer = selectedOffer else { return 0.0 }
        let discountValue = offer.discount_value ?? 0.0
        let type = (offer.discount_type ?? "fixed").lowercased()
        
        if type == "percentage" {
            let discount = subtotalToCheckout * (discountValue / 100.0)
            return min(discount, subtotalToCheckout)
        } else {
            return min(discountValue, subtotalToCheckout)
        }
    }
    
    var taxableAmount: Double {
        max(0.0, subtotalToCheckout - offerDiscount)
    }
    
    var gstAmount: Double {
        taxableAmount * 0.18
    }
    
    var regionTaxAmount: Double {
        var total = 0.0
        let subtotal = subtotalToCheckout
        let ratio = subtotal > 0 ? (taxableAmount / subtotal) : 1.0
        
        for item in itemsToCheckout {
            let cat = item.product.category.lowercased().trimmingCharacters(in: .whitespaces)
            if let rule = regionTaxRules.first(where: { ($0.category ?? "").lowercased().trimmingCharacters(in: .whitespaces) == cat }) {
                let discountedItemPrice = item.totalPrice * ratio
                let itemGST = discountedItemPrice * 0.18
                let amountPlusGST = discountedItemPrice + itemGST
                
                total += amountPlusGST * rule.rate
            }
        }
        return total
    }
    
    var totalTaxAmount: Double {
        gstAmount + regionTaxAmount
    }
    
    var finalTotal: Double {
        let total = subtotalToCheckout + totalTaxAmount - offerDiscount
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
    
    var currentStore: StoreDTO? {
        availableStores.first { $0.id == selectedStoreId }
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
                        
                        checkoutSection(title: "BOUTIQUE FULFILLMENT") {
                            storeCard
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
                        
                        Color.clear.frame(height: 160)
                    }
                    .padding(20)
                }
                
                placeOrderFooter
            }
            .navigationTitle("CHECKOUT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !isPlacingOrder {
                        Button("Cancel") { dismiss() }.foregroundStyle(AppColors.grayLight)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("CHECKOUT").font(.headline).fontWeight(.bold).tracking(4).foregroundStyle(AppColors.gold)
                }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                OrderSuccessView(onComplete: { dismiss() }, purchasedItems: completedPurchaseItems)
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
            // Store picker sheet
            .sheet(isPresented: $showStorePicker) {
                StorePickerSheet(
                    stores: availableStores,
                    selectedId: $selectedStoreId
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
            .alert("Payment Unsuccessful", isPresented: $showError) {
                if errorMessage.contains("network") || errorMessage.contains("connection") {
                    Button("Try Again") {
                        retryOrderRecording()
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedStoreId) {
                Task { await loadOffers() }
            }
            .task {
                // Fetch in parallel to avoid one blocking another
                async let addr: () = loadUserAddresses()
                async let offs: () = loadOffers()
                async let strs: () = loadStores()
                
                let _ = await [addr, offs, strs]
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
    
    private func loadStores() async {
        do {
            let fetched = try await SyncManager.shared.fetchStores()
            await MainActor.run {
                self.availableStores = fetched
                if self.selectedStoreId == nil {
                    self.selectedStoreId = fetched.first?.id
                }
            }
        } catch {
            print("Failed to load stores: \(error)")
        }
    }
    
    private func loadOffers() async {
        do {
            let offers = try await SyncManager.shared.fetchActiveOffers()
            await MainActor.run {
                // Filter strictly for active status
                self.availableOffers = offers.filter { offer in
                    let status = (offer.status ?? "").lowercased().trimmingCharacters(in: .whitespaces)
                    return status == "active"
                }
                print("🏁 CheckoutView: Loaded \(availableOffers.count) active offers")
            }
        } catch {
            print("❌ Failed to load offers: \(error)")
            await MainActor.run {
                self.errorMessage = "Unable to load offers at this time. Please try again later."
            }
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
    
    private var storeCard: some View {
        Button(action: { showStorePicker = true }) {
            HStack(spacing: 16) {
                Image(systemName: "building.2.fill").font(.title2).foregroundStyle(AppColors.gold)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let store = currentStore {
                        Text(store.name)
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(AppColors.pureWhite)
                        Text(store.city)
                            .font(.caption)
                            .foregroundStyle(AppColors.grayLight)
                    } else {
                        Text("Select Boutique")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(AppColors.grayMedium)
                    }
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
                    Text(subtotalToCheckout.formattedPrice).font(.caption2).foregroundStyle(AppColors.grayLight)
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
            ForEach(itemsToCheckout.prefix(3)) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .font(.caption).foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(item.totalPrice.formattedPrice)
                        .font(.caption).foregroundStyle(AppColors.pureWhite)
                }
            }
            
            if itemsToCheckout.count > 3 {
                Text("+ \(itemsToCheckout.count - 3) more items")
                    .font(.caption2).foregroundStyle(AppColors.gold).frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            HStack {
                Text("SUBTOTAL").font(.caption).foregroundStyle(AppColors.grayLight)
                Spacer()
                Text(subtotalToCheckout.formattedPrice).font(.caption).foregroundStyle(AppColors.pureWhite)
            }
            
            if offerDiscount > 0 {
                HStack {
                    Text(selectedOffer?.name.uppercased() ?? "OFFER").font(.caption).foregroundStyle(AppColors.gold)
                    Spacer()
                    Text("-\(offerDiscount.formattedPrice)").font(.caption).foregroundStyle(AppColors.gold)
                }
            }
            
            // ── Step 3 : Tax 18% ────────────────────────────────
            HStack(spacing: 4) {
                Text("TAX")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
                Text("18% × \(taxableAmount.formattedPrice)")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.grayMedium)
                Spacer()
                Text("+" + gstAmount.formattedPrice)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
            }
            
            // ── Step 4 : Region Tax (Category based from Group5 RSMS) ──
            if regionTaxAmount > 0 {
                HStack(spacing: 4) {
                    Text("REGION TAX")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                    
                    let baseAmount = taxableAmount + gstAmount
                    let taxRuleForDisplay = regionTaxRules.first(where: { ($0.category ?? "").lowercased().trimmingCharacters(in: .whitespaces) == itemsToCheckout.first?.product.category.lowercased().trimmingCharacters(in: .whitespaces) })
                    let ratePercent = (taxRuleForDisplay?.rate ?? 0) * 100
                    
                    Text("Admin Tax (\(ratePercent, specifier: "%.1f")%) on \(baseAmount.formattedPrice)")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.grayMedium)
                    
                    Spacer()
                    Text("+" + regionTaxAmount.formattedPrice)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL AMOUNT").font(.subheadline).fontWeight(.bold).foregroundStyle(AppColors.pureWhite)
                    let taxLabel = regionTaxAmount > 0
                        ? "Incl. Tax + Region Tax"
                        : "Incl. Tax"
                    Text(taxLabel)
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.grayMedium)
                }
                Spacer()
                Text(finalTotal.formattedPrice).font(.headline).fontWeight(.bold).foregroundStyle(AppColors.gold)
            }
        }
        .padding(16).darkCard(goldBorder: false)
    }
    
    private var offersCard: some View {
        VStack(spacing: 16) {
            ForEach(availableOffers) { offer in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        if selectedOffer?.id == offer.id {
                            selectedOffer = nil // Deselect
                        } else {
                            selectedOffer = offer
                        }
                    }
                }) {
                    CouponView(offer: offer, isSelected: selectedOffer?.id == offer.id)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var placeOrderFooter: some View {
        VStack(spacing: 0) {
            // Subtle top separator
            Rectangle()
                .fill(AppColors.gold.opacity(0.1))
                .frame(height: 0.5)
            
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
            .disabled(isPlacingOrder || userManager.isLoading || selectedAddressId == nil || selectedStoreId == nil)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(AppColors.background.ignoresSafeArea(edges: .bottom))
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
                
                // 2. Open Razorpay Checkout (with slight delay for UI stability)
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                
                await MainActor.run {
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
                            self.errorMessage = "Your payment could not be completed. Please check your payment details and try again."
                            self.showError = true
                            isPlacingOrder = false
                        }
                    )
                }

            } catch {
                print("Failed to prepare Razorpay: \(error)")
                self.errorMessage = "We're having trouble connecting to our payment service. Please check your internet connection and try again."
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
        let itemsToOrder = itemsToCheckout
        self.failedOrderItems = itemsToOrder // Store in case we need to retry
        
        // 2. Clear cart INSTANTLY so user sees their bag is empty
        if directPurchaseItem == nil { cartManager.clearCart(userId: userId) }
        
        // 3. Record the order in our database in the background
        Task {
            let addressText = currentAddress?.full_address ?? "Unknown Address"
            await performOrderRecording(items: itemsToOrder, userId: userId, shippingAddress: addressText, storeId: selectedStoreId!)
        }
    }
    
    private func performOrderRecording(items: [CartItem], userId: UUID, shippingAddress: String, storeId: UUID) async {
        isPlacingOrder = true
        do {
            try await ordersManager.placeOrder(
                from: items, 
                userId: userId, 
                redeemedPoints: 0,
                offerDiscount: offerDiscount,
                offerId: selectedOffer?.id,
                regionTaxAmount: regionTaxAmount,
                shippingAddress: shippingAddress,
                paymentMethod: selectedPayment,
                storeId: storeId
            )
            completedPurchaseItems = items
            showSuccess = true
            failedOrderItems = []
        } catch {
            print("Order recording failed: \(error)")
            self.errorMessage = "Your payment was successful, but we had trouble saving your order. Please contact support if it doesn't appear in your orders."
            self.showError = true
        }
        isPlacingOrder = false
    }
    
    private func retryOrderRecording() {
        guard let userId = userManager.supabaseUserId else { return }
        let addressText = currentAddress?.full_address ?? "Unknown Address"
        Task {
            await performOrderRecording(items: failedOrderItems, userId: userId, shippingAddress: addressText, storeId: selectedStoreId!)
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
                ScrollView(showsIndicators: false) {
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
                    }
                    .padding(.top, 8)
                }
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
                ScrollView(showsIndicators: false) {
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
                    }
                    .padding(.top, 8)
                }
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

struct StorePickerSheet: View {
    let stores: [StoreDTO]
    @Binding var selectedId: UUID?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(stores) { store in
                            Button(action: {
                                selectedId = store.id
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: selectedId == store.id ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedId == store.id ? AppColors.gold : AppColors.grayDark)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(store.name)
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundStyle(AppColors.pureWhite)
                                        Text(store.city)
                                            .font(.caption)
                                            .foregroundStyle(AppColors.grayLight)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 20).padding(.vertical, 18)
                            }
                            .buttonStyle(.plain)
                            Divider().background(AppColors.grayDark.opacity(0.3)).padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("SELECT BOUTIQUE")
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

