//  ThemeManager.swift
//  User-Side-App
//  Manages the app's appearance (Light/Dark mode)

import SwiftUI

@Observable
class ThemeManager {
    enum AppTheme: String, CaseIterable, Identifiable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"

        var id: String { self.rawValue }

        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }

    var selectedTheme: AppTheme = .dark {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "app_theme")
        }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: saved) {
            self.selectedTheme = theme
        }
    }
}
