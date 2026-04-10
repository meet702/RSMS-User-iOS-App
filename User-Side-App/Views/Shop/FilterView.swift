//
//  FilterView.swift
//  User-Side-App
//
//  Filter bottom sheet for Shop — budget & brand selection
//

import SwiftUI

struct FilterView: View {
    @Bindable var viewModel: ShopViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(AppColors.grayDark)
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            // Header
            HStack {
                Text("Filters")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.pureWhite)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.grayLight)
                        .padding(8)
                        .background(AppColors.surfaceElevated)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // MARK: - Budget
                    budgetSection
                    
                    // Divider
                    Rectangle()
                        .fill(AppColors.grayDark.opacity(0.5))
                        .frame(height: 0.5)
                        .padding(.horizontal, 24)
                    
                    // MARK: - Brands
                    brandSection
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            
            // Bottom action bar
            bottomBar
        }
        .background(AppColors.surfaceDark)
        .presentationCornerRadius(24)
    }
    
    // MARK: - Budget Section
    
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
                .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                Text("Up to \(viewModel.maxBudget.formattedPrice)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.gold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Slider(
                    value: $viewModel.maxBudget,
                    in: 10_000...2_000_000,
                    step: 10_000
                )
                .tint(AppColors.gold)
                
                HStack {
                    Text("₹10K")
                        .font(.caption2)
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text("₹20L")
                        .font(.caption2)
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Brand Section
    
    private var brandSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Brands")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ForEach(viewModel.availableBrands, id: \.self) { brand in
                    Button(action: {
                        if viewModel.selectedBrands.contains(brand) {
                            viewModel.selectedBrands.remove(brand)
                        } else {
                            viewModel.selectedBrands.insert(brand)
                        }
                    }) {
                        HStack {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundStyle(
                                    viewModel.selectedBrands.contains(brand)
                                    ? AppColors.gold : AppColors.pureWhite
                                )
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        viewModel.selectedBrands.contains(brand)
                                        ? AppColors.gold : AppColors.grayDark,
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 20, height: 20)
                                
                                if viewModel.selectedBrands.contains(brand) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.gold)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.background)
                                }
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        HStack(spacing: 12) {
            // Reset
            Button(action: {
                viewModel.resetFilters()
            }) {
                Text("RESET")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .tracking(1)
                    .foregroundStyle(AppColors.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        Capsule()
                            .stroke(AppColors.gold, lineWidth: 1)
                    )
            }
            
            // Apply
            Button(action: { dismiss() }) {
                Text("APPLY")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.goldSubtle)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            AppColors.surfaceDark
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
        )
    }
}

#Preview {
    FilterView(viewModel: ShopViewModel())
}
