//
//  PreviewHelpers.swift
//  User-Side-App
//
//  Convenience extension to inject all required LUXE environment objects for previews.
//

import SwiftUI

extension View {
    /// Injects all six LUXE managers into the environment — use in previews.
    func withLuxePreviewEnvironment() -> some View {
        self
            .environment(CartManager())
            .environment(WishlistManager())
            .environment(UserManager())
            .environment(NavigationManager())
            .environment(ThemeManager())
            .environment(OrdersManager())
    }
}
