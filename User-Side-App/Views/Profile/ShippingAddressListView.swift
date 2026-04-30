//  ShippingAddressListView.swift
//  User-Side-App
//  Premium address management for the LUXE Profile

import SwiftUI

struct ShippingAddressListView: View {
    @Environment(UserManager.self) private var userManager
    @State private var addresses: [AddressDTO] = []
    @State private var isLoading = true
    @State private var showMapPicker = false
    @State private var selectedAddressForEdit: AddressDTO? = nil

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(AppColors.gold)
            } else if addresses.isEmpty {
                emptyState
            } else {
                addressList
            }

            addAddressButton
        }
        .navigationTitle("SHIPPING ADDRESSES")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("SHIPPING ADDRESSES").font(.headline).fontWeight(.bold).tracking(3).foregroundStyle(AppColors.gold)
            }
        }
        .sheet(isPresented: $showMapPicker) {
            MapAddressPickerView(onSave: { structured in
                saveAddress(structured)
                showMapPicker = false
            })
        }
        .onAppear {
            Task {
                await loadAddresses()
            }
        }
    }

    // MARK: - Components

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(AppColors.gold.opacity(0.3))

            VStack(spacing: 8) {
                Text("NO SAVED ADDRESSES")
                    .font(.headline).tracking(2).foregroundStyle(AppColors.pureWhite)
                Text("Add your delivery locations for a\nfaster checkout experience.")
                    .font(.subheadline).foregroundStyle(AppColors.grayLight)
                    .multilineTextAlignment(.center).lineSpacing(4)
            }
        }
    }

    private var addressList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(addresses) { address in
                    addressRow(address)
                }
                Color.clear.frame(height: 100)
            }
            .padding(20)
        }
        .refreshable {
            await loadAddresses()
        }
    }

    private func addressRow(_ address: AddressDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let label = address.label {
                    Text(label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(AppColors.gold)
                        .clipShape(Capsule())
                }

                if address.is_default {
                    Text("DEFAULT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppColors.gold)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .overlay(Capsule().stroke(AppColors.gold, lineWidth: 1))
                }

                Spacer()

                Button(action: { deleteAddress(address) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.red.opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(address.building_name ?? "")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(AppColors.pureWhite)
                Text(address.area_street ?? "")
                    .font(.footnote)
                    .foregroundStyle(AppColors.pureWhite.opacity(0.8))
                Text("\(address.city), \(address.state ?? ""), \(address.pincode ?? "")")
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
            }
        }
        .padding(20)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.grayDark.opacity(0.2), lineWidth: 1))
    }

    private var addAddressButton: some View {
        VStack {
            Spacer()
            Button(action: { showMapPicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                    Text("ADD NEW ADDRESS").tracking(2)
                }
                .font(.subheadline).fontWeight(.bold)
                .foregroundStyle(AppColors.background)
                .padding(.horizontal, 32).padding(.vertical, 18)
                .background(LinearGradient.goldSubtle)
                .clipShape(Capsule())
                .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(PressButtonStyle())
            .padding(.bottom, 30)
        }
    }

    // MARK: - Logic

    private func loadAddresses() async {
        guard let userId = userManager.supabaseUserId else { return }
        isLoading = true
        do {
            addresses = try await SyncManager.shared.fetchAddresses(userId: userId)
        } catch {
            print("Failed to load addresses: \(error)")
        }
        isLoading = false
    }

    private func saveAddress(_ structured: StructuredAddress) {
        guard let userId = userManager.supabaseUserId else { return }
        Task {
            let newAddress = AddressDTO(
                id: UUID(),
                user_id: userId,
                label: "Home",
                building_name: structured.buildingName,
                area_street: structured.areaStreet,
                landmark: structured.landmark,
                city: structured.city,
                state: structured.state,
                pincode: structured.pincode,
                country: structured.country,
                full_address: structured.fullAddress,
                is_default: addresses.isEmpty,
                created_at: nil
            )

            do {
                try await SyncManager.shared.addAddress(address: newAddress)
                await loadAddresses()
            } catch {
                print("Failed to save address: \(error)")
            }
        }
    }

    private func deleteAddress(_ address: AddressDTO) {
        Task {
            do {
                try await SyncManager.shared.deleteAddress(id: address.id)
                await loadAddresses()
            } catch {
                print("Failed to delete address: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShippingAddressListView()
            .withLuxePreviewEnvironment()
    }
}
