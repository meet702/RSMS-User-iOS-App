//
//  GoldButton.swift
//  User-Side-App
//
//  Premium gold CTA button for LUXE
//

import SwiftUI

struct GoldButton: View {
    let title: String
    var isCompact: Bool = false
    var action: () -> Void = {}
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isCompact ? .caption : .subheadline)
                .fontWeight(.bold)
                .tracking(isCompact ? 1 : 2)
                .foregroundStyle(AppColors.alwaysBlack)
                .padding(.horizontal, isCompact ? 16 : 24)
                .padding(.vertical, isCompact ? 8 : 12)
                .background(
                    LinearGradient.goldSubtle
                )
                .clipShape(Capsule())
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Outline Variant

struct GoldOutlineButton: View {
    let title: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .tracking(1)
                .foregroundStyle(AppColors.gold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .overlay(
                    Capsule()
                        .stroke(AppColors.gold, lineWidth: 1)
                )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Press Animation Style

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            GoldButton(title: "SHOP NOW")
            GoldButton(title: "VIEW", isCompact: true)
            GoldOutlineButton(title: "EXPLORE")
        }
    }
}
