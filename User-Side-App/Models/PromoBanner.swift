//
//  PromoBanner.swift
//  User-Side-App
//
//  Promotional banner data model for LUXE
//

import Foundation

struct PromoBanner: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let ctaText: String
    let imageName: String
    let gradientAngle: Double
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        ctaText: String,
        imageName: String = "brand_logo",
        gradientAngle: Double = 45
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.imageName = imageName
        self.gradientAngle = gradientAngle
    }
}
