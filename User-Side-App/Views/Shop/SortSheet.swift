//
//  SortSheet.swift
//  User-Side-App
//
//  Sort options bottom sheet for Shop
//

import SwiftUI

struct SortSheet: View {
    @Binding var selected: ShopViewModel.SortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(AppColors.grayDark)
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            // Title
            Text("Sort By")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            // Options
            VStack(spacing: 0) {
                ForEach(ShopViewModel.SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = option
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(.subheadline)
                                .fontWeight(selected == option ? .semibold : .regular)
                                .foregroundStyle(
                                    selected == option ? AppColors.gold : AppColors.pureWhite
                                )
                            
                            Spacer()
                            
                            if selected == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColors.gold)
                            } else {
                                Circle()
                                    .stroke(AppColors.grayDark, lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                    }
                    
                    if option != ShopViewModel.SortOption.allCases.last {
                        Rectangle()
                            .fill(AppColors.grayDark.opacity(0.3))
                            .frame(height: 0.5)
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .background(AppColors.surfaceDark)
        .presentationDetents([.height(340)])
        .presentationCornerRadius(24)
    }
}

#Preview {
    SortSheet(selected: .constant(.popular))
}
