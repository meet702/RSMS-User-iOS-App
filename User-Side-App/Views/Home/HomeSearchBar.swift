//
//  HomeSearchBar.swift
//  User-Side-App
//
//  Search bar with filter button for LUXE Home tab
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.gold)
            
            // Text field
            TextField("", text: $searchText, prompt:
                Text("Search watches, jewelry, fashion...")
                    .foregroundStyle(AppColors.grayMedium)
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.pureWhite)
            
            // Divider
            Rectangle()
                .fill(AppColors.grayDark)
                .frame(width: 1, height: 20)
            
            // Filter button
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        HomeSearchBar(searchText: .constant(""))
    }
}
