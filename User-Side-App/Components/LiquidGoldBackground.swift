//  LiquidGoldBackground.swift
//  User-Side-App
//  A hyper-premium animated background matching the "Obsidian Glass & Liquid Gold" aesthetic.

import SwiftUI

struct LiquidGoldBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Deep obsidian base
            Color.black.ignoresSafeArea()

            // Gold blobs that swirl slowly
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height

                // Blob 1: Sweeping motion
                Circle()
                    .fill(AppColors.gold.opacity(0.2))
                    .blur(radius: 120)
                    .frame(width: w * 0.8)
                    .offset(x: animate ? w * 0.6 : -w * 0.2,
                            y: animate ? h * 0.4 : -h * 0.1)

                // Blob 2: Rising motion
                Circle()
                    .fill(AppColors.gold.opacity(0.15))
                    .blur(radius: 100)
                    .frame(width: w * 0.7)
                    .offset(x: animate ? -w * 0.2 : w * 0.7,
                            y: animate ? -h * 0.1 : h * 0.8)

                // Blob 3: Center pulse
                Circle()
                    .fill(AppColors.gold.opacity(0.1))
                    .blur(radius: 150)
                    .frame(width: w)
                    .offset(x: w * 0.1, y: animate ? h * 0.7 : h * 0.2)
                    .scaleEffect(animate ? 1.4 : 0.8)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LiquidGoldBackground()
}
