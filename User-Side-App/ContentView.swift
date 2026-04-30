//  ContentView.swift
//  User-Side-App
//  Created by Apple on 10/04/26.

import SwiftUI

struct ContentView: View {
    @Environment(UserManager.self) private var userManager

    var body: some View {
        Group {
            if userManager.isAuthenticated {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: userManager.isAuthenticated)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .withLuxePreviewEnvironment()
}
