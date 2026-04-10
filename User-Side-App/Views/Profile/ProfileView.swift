//
//  ProfileView.swift
//  User-Side-App
//
//  Profile tab placeholder — Phase 4
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
                
                Text("PROFILE")
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
    ProfileView()
}
