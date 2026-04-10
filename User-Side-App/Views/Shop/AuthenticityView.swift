//
//  AuthenticityView.swift
//  User-Side-App
//
//  Luxury USP: Authenticity certificate section
//

import SwiftUI

struct AuthenticityView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.surfaceGold)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .stroke(AppColors.gold.opacity(0.4), lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.gold)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Certificate of Authenticity")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureWhite)
                    
                    Text("Verified & Guaranteed Genuine")
                        .font(.caption)
                        .foregroundStyle(AppColors.gold)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.grayLight)
            }
            .padding(16)
            
            Rectangle()
                .fill(AppColors.grayDark.opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, 16)
            
            // Features
            VStack(spacing: 12) {
                authenticityFeature(
                    icon: "qrcode",
                    title: "Unique QR Code",
                    subtitle: "Scan to verify product authenticity"
                )
                
                authenticityFeature(
                    icon: "lock.shield",
                    title: "Blockchain Tracked",
                    subtitle: "Tamper-proof digital ownership record"
                )
                
                authenticityFeature(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Lifetime Guarantee",
                    subtitle: "Free verification at any LUXE store"
                )
            }
            .padding(16)
        }
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func authenticityFeature(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.gold.opacity(0.7))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.pureWhite)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppColors.grayLight)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        AuthenticityView()
    }
}
