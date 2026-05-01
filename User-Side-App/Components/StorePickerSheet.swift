//
//  StorePickerSheet.swift
//  User-Side-App
//

import SwiftUI

struct StorePickerSheet: View {
    let stores: [StoreDTO]
    @Binding var selectedId: UUID?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(stores) { store in
                            Button(action: {
                                selectedId = store.id
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: selectedId == store.id ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedId == store.id ? AppColors.gold : AppColors.grayDark)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(store.name)
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundStyle(AppColors.pureWhite)
                                        Text(store.city)
                                            .font(.caption)
                                            .foregroundStyle(AppColors.grayLight)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 20).padding(.vertical, 18)
                            }
                            .buttonStyle(.plain)
                            Divider().background(AppColors.grayDark.opacity(0.3)).padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("SELECT BOUTIQUE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
