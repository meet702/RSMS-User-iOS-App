import re

with open('/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App/Views/Cart/CheckoutView.swift', 'r') as f:
    content = f.read()

# 1. Add Region Tax Rules and Direct Purchase State
content = content.replace(
    "@State private var adminTaxRules: [TaxRuleDTO] = []",
    """// Admin-configured regional tax rules fetched from Supabase
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
    }"""
)

# 2. Update offerDiscount math
content = content.replace("cartManager.subtotal * (discountValue / 100.0)", "subtotalToCheckout * (discountValue / 100.0)")
content = content.replace("min(discount, cartManager.subtotal)", "min(discount, subtotalToCheckout)")
content = content.replace("min(discountValue, cartManager.subtotal)", "min(discountValue, subtotalToCheckout)")

# 3. Tax Calculation
content = re.sub(
    r"var taxableAmount: Double {\n\s*max\(0\.0, cartManager\.subtotal - offerDiscount\)\n\s*}",
    """var taxableAmount: Double {
        max(0.0, subtotalToCheckout - offerDiscount)
    }""",
    content
)

content = re.sub(
    r"var adminTaxAmount: Double \{[\s\S]*?var totalTaxAmount: Double \{",
    """var regionTaxAmount: Double {
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
    var totalTaxAmount: Double {""",
    content
)

content = content.replace("gstAmount + adminTaxAmount", "gstAmount + regionTaxAmount")

# 4. Final Total
content = re.sub(
    r"let total = cartManager\.subtotal \+ totalTaxAmount - offerDiscount",
    "let total = subtotalToCheckout + totalTaxAmount - offerDiscount",
    content
)

# 5. Delivery fee - Set to 0.0
content = re.sub(
    r"var deliveryFee: Double \{[\s\S]*?\}",
    """var deliveryFee: Double {
        0.0
    }""",
    content
)

# 6. Load tax rules fetch
content = content.replace("await loadTaxRules()", "")
content = re.sub(
    r"private func loadTaxRules\(\) async \{[\s\S]*?\}",
    """private func loadTaxRules() async {
        do {
            let rules = try await SyncManager.shared.fetchTaxRules()
            await MainActor.run {
                self.regionTaxRules = rules
            }
        } catch {
            await MainActor.run { self.regionTaxRules = [] }
        }
    }""",
    content
)

content = content.replace(".task {\n            await loadOffers()", ".task {\n            await loadOffers()\n            await loadTaxRules()")

# 7. Update UI Strings (Order Summary Card)
content = content.replace("Text(selectedPayment).font(.subheadline).fontWeight(.medium)\n                        .foregroundStyle(AppColors.pureWhite)\n                    Text(cartManager.subtotal.formattedPrice).font(.caption2).foregroundStyle(AppColors.grayLight)", "Text(selectedPayment).font(.subheadline).fontWeight(.medium)\n                        .foregroundStyle(AppColors.pureWhite)\n                    Text(subtotalToCheckout.formattedPrice).font(.caption2).foregroundStyle(AppColors.grayLight)")

content = content.replace("ForEach(cartManager.items.prefix(3)) { item in", "ForEach(itemsToCheckout.prefix(3)) { item in")
content = content.replace("if cartManager.items.count > 3 {", "if itemsToCheckout.count > 3 {")
content = content.replace("Text(\"+ \\(cartManager.items.count - 3) more items\")", "Text(\"+ \\(itemsToCheckout.count - 3) more items\")")

content = content.replace("summaryRow(label: \"SUBTOTAL\", value: cartManager.subtotal.formattedPrice)", "summaryRow(label: \"SUBTOTAL\", value: subtotalToCheckout.formattedPrice)")

# Taxes UI
old_taxes_ui = """// ── Step 3 : GST 18% ────────────────────────────────
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
            }"""

new_taxes_ui = """// ── Step 3 : Tax 18% ────────────────────────────────
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
            }"""
            
content = content.replace(old_taxes_ui, new_taxes_ui)

content = re.sub(r"let formulaText = adminTaxRules.isEmpty[\s\S]*?\n\s*HStack\(spacing: 6\) \{[\s\S]*?Text\(formulaText\)", """HStack(spacing: 6) {
                Image(systemName: "equal.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.grayMedium)
                Text("Amount + Tax + Region Tax")""", content)

content = re.sub(r"let gstPct = 18\n\s*let adminPct = adminTaxRules.reduce\(0.0\) \{ \$0 \+ \$1.rate \}\n\s*let taxLabel = adminPct > 0\n\s*\? \"Incl. GST \\\(gstPct\)% \+ \\\(String\(format: \"%\.1f\", adminPct\)\)% Tax\"\n\s*: \"Incl. 18% GST\"", """let taxLabel = regionTaxAmount > 0
                        ? "Incl. Tax + Region Tax"
                        : "Incl. Tax\"""", content)


# 8. Place order changes
content = content.replace("let itemsToOrder = cartManager.items", "let itemsToOrder = itemsToCheckout")
content = content.replace("cartManager.clearCart(userId: userId)", "if directPurchaseItem == nil { cartManager.clearCart(userId: userId) }")

content = content.replace("let adminTaxRate = adminTaxRules.reduce(0.0) { $0 + $1.rate }", "")
content = content.replace("adminTaxRate: adminTaxRate,", "regionTaxAmount: regionTaxAmount,")

with open('/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App/Views/Cart/CheckoutView.swift', 'w') as f:
    f.write(content)
