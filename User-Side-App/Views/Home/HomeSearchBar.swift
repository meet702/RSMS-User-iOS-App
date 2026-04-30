//  HomeSearchBar.swift
//  User-Side-App
//  Search bar for LUXE Home tab  submitting shows filtered results in a sheet

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
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.grayMedium)

            TextField("", text: $searchText, prompt:
                Text("Search watches, jewelry, fashion")
                    .foregroundStyle(AppColors.grayMedium)
            )
            .accessibilityLabel("Search")
            .accessibilityHint("Enter keywords to find luxury products")
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
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.grayMedium)
                }
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showResults) {
            SeeAllProductsView(
                title: "Results for \"\(searchText)\"",
                products: searchResults
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
