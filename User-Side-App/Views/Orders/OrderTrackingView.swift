//
//  OrderTrackingView.swift
//  User-Side-App
//
//  Detailed shipment tracking and order info view
//

import SwiftUI

struct OrderTrackingView: View {
    let order: Order
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCancelPrompt = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Header (Order ID)
                VStack(spacing: 8) {
                    Text("Order #\(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    Text(order.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                }
                .padding(.top, 16)
                
                // ETA Card
                etaCard
                
                // Timeline Tracking
                trackingTimeline
                
                // Items
                itemsSection
                
                // Cancel Button (if applicable)
                if order.status == .placed || order.status == .processing {
                    cancelButton
                }
                
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ORDER STATUS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(AppColors.gold)
            }
        }
        .alert("Cancel Order", isPresented: $showCancelPrompt) {
            Button("No, keep it", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                onCancel()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to cancel this order? This action cannot be undone.")
        }
    }
    
    // MARK: - ETA Card
    
    @ViewBuilder
    private var etaCard: some View {
        if order.status.isActive {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estimated Delivery")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                    
                    if let eta = order.estimatedDelivery {
                        Text(eta.formatted(date: .complete, time: .omitted))
                            .font(.headline)
                            .foregroundStyle(AppColors.pureWhite)
                    } else {
                        Text("Calculating...")
                            .font(.headline)
                            .foregroundStyle(AppColors.pureWhite)
                    }
                }
                
                Spacer()
                
                Image(systemName: "box.truck.badge.clock.fill")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(AppColors.gold)
            }
            .padding(20)
            .background(AppColors.surfaceGold.opacity(0.3))
            .goldBorder()
        } else if order.status == .delivered {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Delivered On")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                    
                    if let deliveredStep = order.trackingSteps.first(where: { $0.status == .delivered }) {
                        Text(deliveredStep.date?.formatted(date: .complete, time: .omitted) ?? "Recently")
                            .font(.headline)
                            .foregroundStyle(AppColors.pureWhite)
                    }
                }
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppColors.gold)
            }
            .padding(20)
            .darkCard(goldBorder: true)
        } else if order.status == .cancelled {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Status")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                    
                    Text("Cancelled")
                        .font(.headline)
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                Image(systemName: "xmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.red)
            }
            .padding(20)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
    }
    
    // MARK: - Timeline Tracking
    
    private var trackingTimeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tracking")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
                .padding(.bottom, 16)
            
            ForEach(Array(order.trackingSteps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    // Line & Node
                    VStack(spacing: 0) {
                        // Node
                        ZStack {
                            Circle()
                                .fill(step.isCompleted ? AppColors.gold : AppColors.surfaceElevated)
                                .frame(width: 16, height: 16)
                            
                            if step.isCompleted {
                                Circle()
                                    .fill(AppColors.background)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .overlay(
                            // Glow if it's the current active step
                            Circle()
                                .stroke(AppColors.gold.opacity(0.4), lineWidth: 4)
                                .frame(width: 24, height: 24)
                                .opacity((step.isCompleted && (index == order.trackingSteps.count - 1 || !order.trackingSteps[index + 1].isCompleted)) ? 1 : 0)
                        )
                        
                        // Vertical Connecting Line
                        if index < order.trackingSteps.count - 1 {
                            Rectangle()
                                .fill(order.trackingSteps[index + 1].isCompleted ? AppColors.gold : AppColors.surfaceElevated)
                                .frame(width: 2, height: 40)
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(width: 24) // Center alignment
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(step.isCompleted ? AppColors.pureWhite : AppColors.grayLight)
                        
                        Text(step.description)
                            .font(.caption)
                            .foregroundStyle(AppColors.grayMedium)
                        
                        if let date = step.date {
                            Text(date.formatted(date: .omitted, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(AppColors.gold)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.bottom, index < order.trackingSteps.count - 1 ? 24 : 0)
                }
            }
        }
        .padding(20)
        .darkCard()
    }
    
    // MARK: - Items section
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.pureWhite)
            
            ForEach(order.items) { item in
                HStack(spacing: 12) {
                    ZStack {
                        AppColors.surfaceGold
                        Image(systemName: item.product.imageName)
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(AppColors.gold)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.product.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.pureWhite)
                        
                        HStack {
                            if let variant = item.variant {
                                Text("\(variant) · ")
                                    .foregroundStyle(AppColors.grayLight)
                            }
                            Text("Qty: \(item.quantity)")
                                .foregroundStyle(AppColors.grayLight)
                        }
                        .font(.caption)
                    }
                    
                    Spacer()
                    
                    Text((item.priceAtPurchase * Double(item.quantity)).formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.pureWhite)
                }
                .padding(.bottom, item.id == order.items.last?.id ? 0 : 12)
            }
            
            Divider()
                .background(AppColors.grayDark.opacity(0.5))
                .padding(.vertical, 8)
            
            // Totals Breakdowns
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(order.subtotal.formattedPrice)
                        .foregroundStyle(AppColors.pureWhite)
                }
                HStack {
                    Text("Taxes (18%)")
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(order.taxes.formattedPrice)
                        .foregroundStyle(AppColors.pureWhite)
                }
                HStack {
                    Text("Delivery Fee")
                        .foregroundStyle(AppColors.grayLight)
                    Spacer()
                    Text(order.deliveryFee == 0 ? "FREE" : order.deliveryFee.formattedPrice)
                        .foregroundStyle(order.deliveryFee == 0 ? AppColors.gold : AppColors.pureWhite)
                }
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .foregroundStyle(AppColors.pureWhite)
                    Spacer()
                    Text(order.finalTotal.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.gold)
                }
                .padding(.top, 8)
            }
            .font(.subheadline)
        }
        .padding(20)
        .darkCard()
    }
    
    private var cancelButton: some View {
        Button(action: { showCancelPrompt = true }) {
            Text("CANCEL ORDER")
                .font(.subheadline)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .overlay(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(PressButtonStyle())
    }
}
