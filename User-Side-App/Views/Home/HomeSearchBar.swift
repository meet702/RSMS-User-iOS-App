//
//  HomeSearchBar.swift
//  User-Side-App
//
//  Search bar for LUXE Home tab — submitting shows filtered results in a sheet
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var searchText: String
    let products: [Product]
    var onSubmit: (() -> Void)? = nil
    @State private var showResults = false
    
    private var searchResults: [Product] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return [] }
        return products.filter {
            $0.name.lowercased().contains(query) ||
            $0.brand.lowercased().contains(query) ||
            $0.category.lowercased().contains(query)
        }
    }
    
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
            .submitLabel(.search)
            .onSubmit {
                guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                showResults = true
            }
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.grayMedium)
                }
            } else {
                // Divider + filter icon when empty
                Rectangle()
                    .fill(AppColors.grayDark)
                    .frame(width: 1, height: 20)
                
                Button(action: { showResults = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                }
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
        .sheet(isPresented: $showResults) {
            SeeAllProductsView(
                title: searchText.isEmpty ? "All Products" : "Results for \"\(searchText)\"",
                products: searchText.isEmpty ? products : searchResults
            )
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        HomeSearchBar(searchText: .constant(""), products: MockData.products)
    }
    .withLuxePreviewEnvironment()
}
