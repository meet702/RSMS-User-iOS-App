//
//  CartView.swift
//  User-Side-App
//
//  Cart tab placeholder — Phase 3
//

import SwiftUI

struct CartView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
                
                Text("CART")
                    .font(.title2)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                
                Rectangle()
                    .fill(AppColors.gold.opacity(0.3))
                    .frame(width: 40, height: 1)
            }
        }
    }
}

#Preview {
    CartView()
}
