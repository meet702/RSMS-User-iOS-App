//
//  OrderCardView.swift
//  User-Side-App
//
//  Summary card for an order in the Orders tab list
//

import SwiftUI

struct OrderCardView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: Order ID & Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.orderNumber)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    
                    Text(order.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                }
                
                Spacer()
                
                statusPill
            }
            
            Rectangle()
                .fill(AppColors.grayDark.opacity(0.3))
                .frame(height: 1)
            
            // Items Preview
            HStack(spacing: 12) {
                // Image of first item
                if let firstItem = order.items.first {
                    ZStack {
                        AppColors.surfaceGold
                        Image(systemName: firstItem.product.imageName)
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(AppColors.gold)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstItem.product.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.pureWhite)
                            .lineLimit(1)
                        
                        Text(firstItem.product.brand)
                            .font(.caption2)
                            .foregroundStyle(AppColors.gold)
                        
                        if order.items.count > 1 {
                            Text("+ \(order.items.count - 1) more item(s)")
                                .font(.caption)
                                .foregroundStyle(AppColors.grayLight)
                        }
                    }
                }
                
                Spacer()
                
                // Total Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                    Text(order.finalTotal.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                }
            }
        }
        .padding(16)
        .darkCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(order.status.isActive ? AppColors.gold.opacity(0.3) : .clear, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var statusPill: some View {
        let isWarning = order.status == .cancelled
        let isActive = order.status.isActive
        
        Text(order.status.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1)
            .foregroundStyle(isWarning ? .red : (isActive ? AppColors.background : AppColors.gold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isWarning ? Color.red.opacity(0.2) : (isActive ? AppColors.gold : AppColors.surfaceGold))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isWarning ? .red : AppColors.gold, lineWidth: isActive ? 0 : 1)
            )
    }
}
