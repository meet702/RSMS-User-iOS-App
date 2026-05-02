//
//  CategoryCard.swift
//  User-Side-App
//
//  Premium iOS-standard category card — elegant pill with icon, name, and count
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 12) {
                // Circular icon area
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceDark)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.gold.opacity(0.8), AppColors.gold.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 72, height: 72)
                    
                    // Subtle inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.gold.opacity(0.15), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 36
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    // Icon
                    Image(systemName: category.icon)
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.goldLight, AppColors.gold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: AppColors.gold.opacity(0.3), radius: 3)
                }
                
                // Elegant Label
                Text(category.name.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(AppColors.pureWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
        }
        .buttonStyle(CategoryButtonStyle())
        .accessibilityLabel("Category: \(category.name)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to view products in \(category.name)")
    }
}

// MARK: - Custom Button Style

struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        HStack(spacing: 12) {
            CategoryCard(category: MockData.categories[0])
            CategoryCard(category: MockData.categories[1])
            CategoryCard(category: MockData.categories[2])
            CategoryCard(category: MockData.categories[3])
        }
    }
}
