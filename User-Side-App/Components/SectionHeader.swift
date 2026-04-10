//
//  SectionHeader.swift
//  User-Side-App
//
//  Reusable section header: "Title" + "See All →"
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var showSeeAll: Bool = true
    var onSeeAll: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
            
            Spacer()
            
            if showSeeAll {
                Button(action: { onSeeAll?() }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(AppColors.gold)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            SectionHeader(title: "New Arrivals")
            SectionHeader(title: "Categories", showSeeAll: false)
        }
    }
}
