//
//  CategoryCard.swift
//  User-Side-App
//
//  Category tile with icon for LUXE
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    var onTap: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 12) {
                // Icon circle with gold border
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceDark)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDark.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(category.icon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }
                
                // Category name
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(PressButtonStyle())
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        HStack(spacing: 16) {
            CategoryCard(category: Category(name: "Watches", icon: "clock.fill", productCount: 42))
            CategoryCard(category: Category(name: "Jewelry", icon: "sparkles", productCount: 38))
            CategoryCard(category: Category(name: "Fashion", icon: "tshirt.fill", productCount: 65))
        }
    }
}
