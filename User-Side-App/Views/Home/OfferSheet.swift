//  OfferSheet.swift
//  User-Side-App
//  Dedicated sheet to display active promotional offers.

import SwiftUI

struct OfferSheet: View {
    @Environment(NavigationManager.self) private var navManager
    let offers: [OfferDTO]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    if offers.isEmpty {
                        emptyState
                    } else {
                        offersList
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Exclusive Offers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        navManager.showOffers = false
                    }
                    .foregroundStyle(AppColors.gold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "tag.slash.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.grayDark)

            Text("No Active Offers")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.pureWhite)

            Text("Check back soon for exclusive rewards and seasonal collections.")
                .font(.subheadline)
                .foregroundStyle(AppColors.grayLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var offersList: some View {
        VStack(spacing: 16) {
            ForEach(offers) { offer in
                OfferRowView(offer: offer)
            }
        }
        .padding(20)
    }
}

private struct OfferRowView: View {
    let offer: OfferDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.pureWhite)

                    if let code = offer.coupon_code {
                        Text("CODE: \(code)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(1)
                            .foregroundStyle(AppColors.gold)
                    }
                }

                Spacer()

                // Discount Label
                let discountValue = offer.discount_value ?? 0.0
                let type = (offer.discount_type ?? "fixed").lowercased()
                let discountText = type == "percentage" ? "\(Int(discountValue))% OFF" : "\(Int(discountValue)) OFF"

                Text(discountText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.gold.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.gold.opacity(0.3), lineWidth: 1))
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(20)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1))
    }
}
