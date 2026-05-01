import urllib.request

# Download the baseline CheckoutView from git commit to ensure we have the exact right starting point
with open('/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App/Views/Cart/CheckoutView.swift', 'r') as f:
    content = f.read()

# 1. State changes
content = content.replace(
    "@State private var adminTaxRules: [TaxRuleDTO] = []",
    """@State private var regionTaxRules: [TaxRuleDTO] = []
    
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
    }"""
)

content = content.replace("cartManager.subtotal * (discountValue / 100.0)", "subtotalToCheckout * (discountValue / 100.0)")
content = content.replace("min(discount, cartManager.subtotal)", "min(discount, subtotalToCheckout)")
content = content.replace("min(discountValue, cartManager.subtotal)", "min(discountValue, subtotalToCheckout)")

# 2. Taxes logic
old_taxes = """    var taxableAmount: Double {
        max(0.0, cartManager.subtotal - offerDiscount)
    }
    
    /// 18% GST applied to the taxable base — matches OrdersManager line:
    ///   taxes = max(0.0, (subtotal - discount)) * 0.18
    var gstAmount: Double {
        taxableAmount * 0.18
    }
    
    /// Sum of all admin-configured tax rules from Supabase applied to taxable amount
    var adminTaxAmount: Double {
        let totalRate = adminTaxRules.reduce(0.0) { $0 + $1.rate }
        return taxableAmount * (totalRate / 100.0)
    }
    
    /// Combined tax = GST (18%) + all admin taxes
    var totalTaxAmount: Double {
        gstAmount + adminTaxAmount
    }
    
    /// Delivery fee logic (Free over 1,000,000 INR)
    var deliveryFee: Double {
        cartManager.subtotal >= 1_000_000 ? 0.0 : 15_000.0
    }
    
    /// Final total = subtotal + totalTax + delivery - discount
    var finalTotal: Double {
        let total = cartManager.subtotal + totalTaxAmount + deliveryFee - offerDiscount
        return max(1.0, total) // Prevent Razorpay crash on <= 0 payments
    }"""

new_taxes = """    var taxableAmount: Double {
        max(0.0, subtotalToCheckout - offerDiscount)
    }
    
    /// 18% GST applied to the taxable base — matches OrdersManager line:
    ///   taxes = max(0.0, (subtotal - discount)) * 0.18
    var gstAmount: Double {
        taxableAmount * 0.18
    }
    
    /// Regional tax (Admin tax) calculated per category based on Group5 RSMS taxation model
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
                
                // rule.rate is already stored as a decimal in the DB (e.g. 0.04 for 4%)
                total += amountPlusGST * rule.rate
            }
        }
        return total
    }
    
    /// Combined tax = GST (18%) + Region Tax
    var totalTaxAmount: Double {
        gstAmount + regionTaxAmount
    }
    
    /// Delivery fee logic
    var deliveryFee: Double {
        0.0
    }
    
    /// Final total = subtotal + totalTax + delivery - discount
    var finalTotal: Double {
        let total = subtotalToCheckout + totalTaxAmount - offerDiscount
        return max(1.0, total) // Prevent Razorpay crash on <= 0 payments
    }"""

content = content.replace(old_taxes, new_taxes)

# 3. Fix loadTaxRules
old_loadTax = """    private func loadTaxRules() async {
        guard let storeId = selectedStoreId else { return }
        do {
            let rules = try await SyncManager.shared.fetchTaxRules(storeId: storeId)
            await MainActor.run {
                self.adminTaxRules = rules
                print("🧾 CheckoutView: Loaded \\(rules.count) admin tax rule(s) for store \\(storeId)")
            }
        } catch {
            // Non-fatal: if tax_rules table doesn't exist yet, just use 0 admin tax
            print("⚠️ CheckoutView: Could not load tax rules (\\(error.localizedDescription)) — continuing with GST only")
            await MainActor.run { self.adminTaxRules = [] }
        }
    }"""
new_loadTax = """    private func loadTaxRules() async {
        do {
            let rules = try await SyncManager.shared.fetchTaxRules()
            await MainActor.run {
                self.regionTaxRules = rules
            }
        } catch {
            await MainActor.run { self.regionTaxRules = [] }
        }
    }"""
content = content.replace(old_loadTax, new_loadTax)

# 4. Remove onChange selectedStoreId
content = content.replace("""            .onChange(of: selectedStoreId) {
                Task {
                    await loadOffers()
                    await loadTaxRules()
                }
            }""", """            .onChange(of: selectedStoreId) {
                Task {
                    await loadOffers()
                }
            }""")
content = content.replace(".task {\n            await loadOffers()\n        }", ".task {\n            await loadOffers()\n            await loadTaxRules()\n        }")

# 5. Order Summary UI
content = content.replace("Text(cartManager.subtotal.formattedPrice)", "Text(subtotalToCheckout.formattedPrice)")
content = content.replace("ForEach(cartManager.items.prefix(3)) { item in", "ForEach(itemsToCheckout.prefix(3)) { item in")
content = content.replace("if cartManager.items.count > 3 {", "if itemsToCheckout.count > 3 {")
content = content.replace("Text(\"+ \\(cartManager.items.count - 3) more items\")", "Text(\"+ \\(itemsToCheckout.count - 3) more items\")")
content = content.replace("summaryRow(label: \"SUBTOTAL\", value: cartManager.subtotal.formattedPrice)", "summaryRow(label: \"SUBTOTAL\", value: subtotalToCheckout.formattedPrice)")

old_taxes_ui = """            // ── Step 3 : GST 18% ────────────────────────────────
            HStack(spacing: 4) {
                Text("GST")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
                Text("18% × \\(taxableAmount.formattedPrice)")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.grayMedium)
                Spacer()
                Text("+" + gstAmount.formattedPrice)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
            }
            
            // ── Step 4 : Admin Tax Rules (from Supabase) ────────────
            ForEach(adminTaxRules) { rule in
                HStack(spacing: 4) {
                    Text(rule.name.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                    Text("\\(rule.rate, specifier: "%.1f")% × \\(taxableAmount.formattedPrice)")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.grayMedium)
                    Spacer()
                    Text("+" + (taxableAmount * (rule.rate / 100.0)).formattedPrice)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            
            // ── Step 5 : Delivery ─────────────────────────────────
            HStack(spacing: 4) {
                Text("DELIVERY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
                Text(deliveryFee == 0.0 ? "(Free Over 1M)" : "(Standard)")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.grayMedium)
                Spacer()
                Text(deliveryFee == 0.0 ? "FREE" : "+" + deliveryFee.formattedPrice)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(deliveryFee == 0.0 ? AppColors.gold : AppColors.grayLight)
            }
            
            // ── Formula badge ───────────────────────────────────
            let formulaText = adminTaxRules.isEmpty
                ? "Subtotal + GST (18%) + Delivery − Discount"
                : "Subtotal + GST (18%) + Tax + Delivery − Discount"
            HStack(spacing: 6) {
                Image(systemName: "equal.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.grayMedium)
                Text(formulaText)
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.grayMedium)
                    .italic()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            // ── Final Total ───────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL AMOUNT")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    let gstPct = 18
                    let adminPct = adminTaxRules.reduce(0.0) { $0 + $1.rate }
                    let taxLabel = adminPct > 0
                        ? "Incl. GST \\(gstPct)% + \\(String(format: "%.1f", adminPct))% Tax"
                        : "Incl. 18% GST"
                    Text(taxLabel)
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.grayMedium)
                }"""

new_taxes_ui = """            // ── Step 3 : Tax 18% ────────────────────────────────
            HStack(spacing: 4) {
                Text("TAX")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.grayLight)
                Text("18% × \\(taxableAmount.formattedPrice)")
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
                    
                    Text("Admin Tax (\\(ratePercent, specifier: "%.1f")%) on \\(baseAmount.formattedPrice)")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.grayMedium)
                    
                    Spacer()
                    Text("+" + regionTaxAmount.formattedPrice)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            
            // ── Formula badge ───────────────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "equal.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.grayMedium)
                Text("Amount + Tax + Region Tax")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.grayMedium)
                    .italic()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
            
            Divider().background(AppColors.grayDark.opacity(0.3))
            
            // ── Final Total ───────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL AMOUNT")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    let taxLabel = regionTaxAmount > 0
                        ? "Incl. Tax + Region Tax"
                        : "Incl. Tax"
                    Text(taxLabel)
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.grayMedium)
                }"""

content = content.replace(old_taxes_ui, new_taxes_ui)

# 6. Orders Logic
content = content.replace("let itemsToOrder = cartManager.items", "let itemsToOrder = itemsToCheckout")
content = content.replace("cartManager.clearCart(userId: userId)", "if directPurchaseItem == nil { cartManager.clearCart(userId: userId) }")

old_place = """    private func performOrderRecording(items: [CartItem], userId: UUID, shippingAddress: String, storeId: UUID) async {
        isPlacingOrder = true
        let adminTaxRate = adminTaxRules.reduce(0.0) { $0 + $1.rate }
        do {
            try await ordersManager.placeOrder(
                from: items, 
                userId: userId, 
                redeemedPoints: 0,
                offerDiscount: offerDiscount,
                offerId: selectedOffer?.id,
                adminTaxRate: adminTaxRate,
                shippingAddress: shippingAddress,
                paymentMethod: selectedPayment,
                storeId: storeId
            )"""

new_place = """    private func performOrderRecording(items: [CartItem], userId: UUID, shippingAddress: String, storeId: UUID) async {
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
            )"""
            
content = content.replace(old_place, new_place)

with open('/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App/Views/Cart/CheckoutView.swift', 'w') as f:
    f.write(content)
