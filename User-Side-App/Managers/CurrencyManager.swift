//  CurrencyManager.swift
//  User-Side-App

import Foundation
import Supabase

@Observable
final class CurrencyManager {
    static let shared = CurrencyManager()

    var rates: [String: ExchangeRate] = [:]
    var currentRate: Double = 1.0
    var currentSymbol: String = ""
    var currentCurrencyCode: String = "INR"
    var currentLocaleId: String = "en_IN"

    private init() {}

    @MainActor
    func fetchRates() async {
        do {
            let fetchedRates: [ExchangeRate] = try await SupabaseManager.shared.client
                .from("exchange_rates")
                .select()
                .execute()
                .value

            for rate in fetchedRates {
                self.rates[rate.currency_code] = rate
            }

            updateToLocalCurrency()
        } catch {
            print("[CurrencyManager] Error fetching exchange rates: \(error.localizedDescription)")
            // Fallback to defaults
            self.currentRate = 1.0
            self.currentSymbol = ""
            self.currentCurrencyCode = "INR"
            self.currentLocaleId = "en_IN"
        }
    }

    @MainActor
    func updateToLocalCurrency() {
        guard !rates.isEmpty else { return }

        // Detect system currency code (e.g., "USD", "EUR")
        let localCurrencyCode = Locale.current.currency?.identifier ?? "USD"

        if let rate = rates[localCurrencyCode] {
            self.currentRate = rate.rate
            self.currentSymbol = rate.symbol
            self.currentCurrencyCode = rate.currency_code
            self.currentLocaleId = rate.locale_id
        } else {
            // Fallback to USD if the local currency isn't supported, or INR if USD isn't available
            if let usd = rates["USD"] {
                self.currentRate = usd.rate
                self.currentSymbol = usd.symbol
                self.currentCurrencyCode = usd.currency_code
                self.currentLocaleId = usd.locale_id
            } else if let inr = rates["INR"] {
                self.currentRate = inr.rate
                self.currentSymbol = inr.symbol
                self.currentCurrencyCode = inr.currency_code
                self.currentLocaleId = inr.locale_id
            }
        }

        print("[CurrencyManager] Set active currency to \(currentCurrencyCode) (Rate: \(currentRate))")
    }
}
