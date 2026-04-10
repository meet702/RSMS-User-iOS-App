//
//  AppTheme.swift
//  User-Side-App
//
//  LUXE Design System — Black + Gold + White
//

import SwiftUI

// MARK: - App Colors

enum AppColors {
    // Core backgrounds
    static let background = Color.black
    static let surfaceDark = Color(hex: "111111")
    static let surfaceElevated = Color(hex: "1A1A1A")
    static let surfaceGold = Color(hex: "1A1508")
    
    // Gold palette
    static let gold = Color(hex: "C9A96E")
    static let goldLight = Color(hex: "E8D5A3")
    static let goldDark = Color(hex: "A8893E")
    
    // Neutrals
    static let pureWhite = Color.white
    static let offWhite = Color(hex: "F5F5F5")
    static let grayLight = Color(hex: "999999")
    static let grayMedium = Color(hex: "666666")
    static let grayDark = Color(hex: "333333")
}

// MARK: - Hex Color Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let goldShimmer = LinearGradient(
        colors: [AppColors.goldDark, AppColors.gold, AppColors.goldLight, AppColors.gold, AppColors.goldDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goldSubtle = LinearGradient(
        colors: [AppColors.gold, AppColors.goldLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldVertical = LinearGradient(
        colors: [AppColors.gold, AppColors.goldDark],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let darkCard = LinearGradient(
        colors: [AppColors.surfaceDark, Color(hex: "0A0A0A")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let bannerGold = LinearGradient(
        colors: [AppColors.surfaceGold, AppColors.background],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Modifiers

struct DarkCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    var goldBorder: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        goldBorder ? AppColors.gold.opacity(0.3) : .clear,
                        lineWidth: 1
                    )
            )
    }
}

struct GoldBorderStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.gold.opacity(0.6), AppColors.goldDark.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func darkCard(cornerRadius: CGFloat = 16, goldBorder: Bool = false) -> some View {
        modifier(DarkCardStyle(cornerRadius: cornerRadius, goldBorder: goldBorder))
    }
    
    func goldBorder(cornerRadius: CGFloat = 16) -> some View {
        modifier(GoldBorderStyle(cornerRadius: cornerRadius))
    }
}

// MARK: - Price Formatter

extension Double {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: self)) ?? "₹\(Int(self))"
    }
}
