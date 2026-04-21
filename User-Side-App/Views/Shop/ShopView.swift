//
//  ShopView.swift
//  User-Side-App
//
//  LUXE Shop Tab — Product listing with filters, sort, search
//

import SwiftUI

struct ShopView: View {
    @State private var viewModel = ShopViewModel()
    @State private var showFilter = false
    @State private var showSort = false
    @Environment(WishlistManager.self) private var wishlistManager
    @Environment(NavigationManager.self) private var navManager
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Search bar
                    searchBar
                    
                    // Category chips
                    categoryChips
                    
                    // Controls row (result count + sort/filter)
                    controlsRow
                    
                    // Product grid
                    productGrid
                    
                    // Bottom spacing
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 8)
            }
            .refreshable {
                await viewModel.loadData()
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SHOP")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(6)
                        .foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: WishlistView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "heart")
                                .font(.system(size: 18))
                                .foregroundStyle(AppColors.pureWhite)
                            
                            if wishlistManager.count > 0 {
                                Circle()
                                    .fill(AppColors.gold)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .sheet(isPresented: $showFilter) {
                FilterView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showSort) {
                SortSheet(selected: Bindable(viewModel).sortOption)
            }
        }
        .onAppear {
            if let pending = navManager.pendingCategoryFilter {
                withAnimation {
                    viewModel.selectedCategory = pending
                }
                navManager.pendingCategoryFilter = nil
            }
            if let search = navManager.pendingSearchText {
                withAnimation {
                    viewModel.searchText = search
                }
                navManager.pendingSearchText = nil
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.gold)
            
            TextField("", text: $viewModel.searchText, prompt:
                Text("Search products, brands...")
                    .foregroundStyle(AppColors.grayMedium)
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.pureWhite)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.grayLight)
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
    }
    
    // MARK: - Category Chips
    
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "All" chip
                chipButton(label: "All", isSelected: viewModel.selectedCategory == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedCategory = nil
                    }
                }
                
                ForEach(viewModel.categoryNames, id: \.self) { name in
                    chipButton(label: name, isSelected: viewModel.selectedCategory == name) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedCategory = viewModel.selectedCategory == name ? nil : name
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? AppColors.background : AppColors.pureWhite)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.gold : AppColors.surfaceDark)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? .clear : AppColors.grayDark.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(PressButtonStyle())
    }
    
    // MARK: - Controls Row
    
    private var controlsRow: some View {
        HStack {
            Text("\(viewModel.filteredProducts.count) Results")
                .font(.caption)
                .foregroundStyle(AppColors.grayLight)
            
            Spacer()
            
            // Sort button
            Button(action: { showSort = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11))
                    Text("Sort")
                        .font(.caption)
                }
                .foregroundStyle(AppColors.pureWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.surfaceDark)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1)
                )
            }
            
            // Filter button
            Button(action: { showFilter = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 11))
                    Text("Filter")
                        .font(.caption)
                    
                    if viewModel.activeFilterCount > 0 {
                        Text("\(viewModel.activeFilterCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AppColors.background)
                            .padding(4)
                            .background(AppColors.gold)
                            .clipShape(Circle())
                    }
                }
                .foregroundStyle(AppColors.pureWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.surfaceDark)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            viewModel.activeFilterCount > 0
                            ? AppColors.gold.opacity(0.5) : AppColors.grayDark.opacity(0.5),
                            lineWidth: 1
                        )
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Product Grid
    
    private var productGrid: some View {
        Group {
            if viewModel.filteredProducts.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(AppColors.gold.opacity(0.3))
                    
                    Text("No products found")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                    
                    Button(action: { viewModel.resetFilters() }) {
                        Text("Clear Filters")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.gold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.filteredProducts) { product in
                        NavigationLink(value: product) {
                            ProductCardGrid(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ShopView()
        .withLuxePreviewEnvironment()
}
