//
//  CouponComponents.swift
//  User-Side-App
//
//  Custom UI components for the "Ticket" style coupon redesign.
//

import SwiftUI

/// A ticket shape with semi-circular cutouts on the top and bottom.
struct CouponTicketShape: Shape {
    let cutoutRadius: CGFloat = 8
    let cutoutOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 12
        
        // Start from top-left
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge to cutout
        path.addLine(to: CGPoint(x: cutoutOffset - cutoutRadius, y: 0))
        
        // Top cutout
        path.addArc(center: CGPoint(x: cutoutOffset, y: 0),
                    radius: cutoutRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: true)
        
        // Top edge to top-right
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        
        // Bottom edge to cutout
        path.addLine(to: CGPoint(x: cutoutOffset + cutoutRadius, y: rect.height))
        
        // Bottom cutout
        path.addArc(center: CGPoint(x: cutoutOffset, y: rect.height),
                    radius: cutoutRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: true)
        
        // Bottom edge to bottom-left
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        path.closeSubpath()
        return path
    }
}

/// A vertical dotted line for the coupon divider.
struct DottedLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundStyle(AppColors.grayMedium.opacity(0.5))
        }
    }
}

/// The main Coupon View that displays an OfferDTO.
struct CouponView: View {
    let offer: OfferDTO
    let isSelected: Bool
    
    private let leftSectionWidth: CGFloat = 110
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: Discount Amount
            VStack(alignment: .center, spacing: 4) {
                if (offer.discount_type ?? "percentage").lowercased() == "percentage" {
                    Text("\(Int(offer.discount_value ?? 0))%")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(AppColors.gold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("OFF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.gold.opacity(0.8))
                } else {
                    Text("₹\(Int(offer.discount_value ?? 0))")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppColors.gold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("OFF")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.gold.opacity(0.8))
                }
            }
            .frame(width: leftSectionWidth)
            
            // Dotted Divider
            DottedLine()
                .frame(width: 1)
                .padding(.vertical, 10)
            
            // Right side: Name and Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(offer.name.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppColors.pureWhite)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.gold)
                            .font(.system(size: 16))
                    }
                }
                
                if let code = offer.coupon_code {
                    Text(code)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                if let endDate = offer.end_date {
                    Text("Valid until: \(formatDate(endDate))")
                        .font(.system(size: 8))
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 90)
        .background(
            CouponTicketShape(cutoutOffset: leftSectionWidth)
                .fill(isSelected ? AppColors.surfaceElevated : AppColors.surfaceDark)
        )
        .overlay(
            CouponTicketShape(cutoutOffset: leftSectionWidth)
                .stroke(isSelected ? AppColors.gold : AppColors.grayDark.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Simple formatter for demonstration
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}
