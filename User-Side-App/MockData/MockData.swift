//  MockData.swift
//  User-Side-App
//  7 curated DIOR products  one from each key category.
//  imageURL points to stable Pexels CDN images (no API key needed).

import Foundation

enum MockData {

    // MARK: - Categories

    static let categories: [Category] = [
        Category(name: "Watches",     icon: "applewatch",          imageURL: "https://images.pexels.com/photos/1257733/pexels-photo-1257733.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 42),
        Category(name: "Jewelry",     icon: "sparkles",             imageURL: "https://images.pexels.com/photos/1458867/pexels-photo-1458867.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 38),
        Category(name: "Fashion",     icon: "tshirt.fill",          imageURL: "https://images.pexels.com/photos/994517/pexels-photo-994517.jpeg?auto=compress&cs=tinysrgb&w=150",  productCount: 65),
        Category(name: "Handbags",    icon: "bag.fill",             imageURL: "https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 29),
        Category(name: "Shoes",       icon: "shoe.fill",             imageURL: "https://images.pexels.com/photos/1458594/pexels-photo-1458594.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 34),
        Category(name: "Fragrances",  icon: "drop.fill",            imageURL: "https://images.pexels.com/photos/1556704/pexels-photo-1556704.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 21),
        Category(name: "Accessories", icon: "sunglasses",           imageURL: "https://images.pexels.com/photos/1362558/pexels-photo-1362558.jpeg?auto=compress&cs=tinysrgb&w=150", productCount: 47),
    ]

    // MARK: - Products  (7 items  one from each category)
    // All imageURLs are free Pexels CDN images, no auth required.

    static let products: [Product] = [

        // 1. WATCHES
        Product(
            name: "Grand Bal Pliss Soleil",
            brand: "DIOR",
            price: 1_250_000,
            originalPrice: 1_450_000,
            imageName: "watch_submariner",
            imageURL: "https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Watches",
            isNew: true,
            rating: 4.9,
            isFeatured: true,
            description: "The Grand Bal Pliss Soleil automatic watch features a mesmerizing oscillating weight inspired by Dior Haute Couture. Crafted in steel and gold with a mother-of-pearl dial, this 36mm masterpiece embodies the art of movement."
        ),

        // 2. JEWELRY
        Product(
            name: "Rose des Vents Bracelet",
            brand: "DIOR",
            price: 1,
            imageName: "jewelry_bracelet",
            imageURL: "https://images.pexels.com/photos/1616428/pexels-photo-1616428.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Jewelry",
            isNew: true,
            rating: 4.9,
            isFeatured: true,
            description: "The Rose des Vents bracelet, a Victoire de Castellane creation, features the Maison's lucky star set in 18K yellow gold with turquoise and a diamond. A contemporary talisman inspired by Christian Dior's love of the stars."
        ),

        // 3. FASHION
        Product(
            name: "Oblique Jacquard Jacket",
            brand: "DIOR",
            price: 195_000,
            originalPrice: 230_000,
            imageName: "tshirt_prada",
            imageURL: "https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Fashion",
            isNew: true,
            rating: 4.7,
            isFeatured: true,
            description: "This iconic Dior Oblique jacquard jacket features the signature monogram motif reimagined by Kim Jones. Crafted from technical cotton blend with a relaxed silhouette. A modern wardrobe essential from the Maison."
        ),

        // 4. HANDBAGS
        Product(
            name: "Lady Dior",
            brand: "DIOR",
            price: 875_000,
            imageName: "handbag_classic",
            imageURL: "https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Handbags",
            isNew: false,
            rating: 5.0,
            isFeatured: true,
            description: "The Lady Dior  an icon since 1995, beloved by Princess Diana. Crafted in supple cannage lambskin with gold-tone D.I.O.R. charms. The quilted motif is inspired by the Napoleon III chairs Christian Dior loved."
        ),

        // 5. SHOES
        Product(
            name: "B23 High-Top Sneakers",
            brand: "DIOR",
            price: 72_000,
            originalPrice: 85_000,
            imageName: "shoe_gucci",
            imageURL: "https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Shoes",
            rating: 4.5,
            isFeatured: true,
            description: "The B23 high-top sneaker features the Dior Oblique motif on transparent technical canvas. With a white rubber sole and calfskin details, it's a contemporary icon that bridges streetwear and haute couture."
        ),

        // 6. FRAGRANCES
        Product(
            name: "Sauvage Elixir",
            brand: "DIOR",
            price: 32_000,
            originalPrice: 38_000,
            imageName: "fragrance_oudwood",
            imageURL: "https://images.pexels.com/photos/965989/pexels-photo-965989.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Fragrances",
            rating: 4.6,
            isFeatured: false,
            description: "Sauvage Elixir is the most concentrated expression of the iconic Sauvage line. A rich elixir of spices, woods, and amber notes by Franois Demachy. A fragrance of raw, noble elegance for the modern man."
        ),

        // 7. ACCESSORIES
        Product(
            name: "DiorBlackSuit Sunglasses",
            brand: "DIOR",
            price: 18_500,
            imageName: "sunglasses_rayban",
            imageURL: "https://images.pexels.com/photos/1362558/pexels-photo-1362558.jpeg?auto=compress&cs=tinysrgb&w=600",
            category: "Accessories",
            isNew: true,
            rating: 4.7,
            isFeatured: true,
            description: "The DiorBlackSuit navigator sunglasses feature the CD Diamond signature on the temples. Crafted in lightweight metal with grey gradient lenses. A refined silhouette embodying Dior's timeless Parisian elegance."
        ),
    ]

    // MARK: - Filtered Collections

    static var featuredProducts: [Product] {
        products.filter { $0.isFeatured }
    }

    static var newArrivals: [Product] {
        products.filter { $0.isNew }
    }

    static var recommendations: [Product] {
        Array(products.shuffled())
    }

    // MARK: - Promotional Banners

    static let banners: [PromoBanner] = [
        PromoBanner(
            title: "Signature Collection",
            subtitle: "Discover Our Finest Selections",
            ctaText: "SHOP NOW",
            imageName: "banner_summer",
            targetCategory: "All",
            gradientAngle: 45
        ),
        PromoBanner(
            title: "Exclusive Offers",
            subtitle: "On Selected Luxury Items",
            ctaText: "EXPLORE",
            imageName: "banner_watch",
            targetCategory: "All",
            gradientAngle: 135
        ),
        PromoBanner(
            title: "New Arrivals",
            subtitle: "Experience True Craftsmanship",
            ctaText: "DISCOVER",
            imageName: "jewelry_bracelet",
            targetCategory: "All",
            gradientAngle: 90
        ),
    ]

    // MARK: - Product Variants

    static func variants(for product: Product) -> [String] {
        switch product.category {
        case "Watches":     return ["36mm", "38mm", "40mm", "42mm"]
        case "Jewelry":     return ["Small", "Medium", "Large"]
        case "Fashion":     return ["XS", "S", "M", "L", "XL"]
        case "Handbags":    return ["Mini", "Small", "Medium", "Large"]
        case "Shoes":       return ["EU 38", "EU 39", "EU 40", "EU 41", "EU 42"]
        case "Fragrances":  return ["30ml", "50ml", "100ml", "150ml"]
        case "Accessories": return ["One Size"]
        default:            return ["Standard"]
        }
    }

    // MARK: - Mock Orders

    static let orders: [Order] = [
        // Active Order
        Order(
            orderNumber: "DIOR-9482-771",
            date: Date().addingTimeInterval(-86400 * 2),
            items: [
                OrderItem(product: products[0], variant: "36mm", quantity: 1, priceAtPurchase: products[0].price)
            ],
            subtotal: products[0].price,
            taxes: products[0].price * 0.18,
            deliveryFee: 0,
            status: .placed,
            trackingSteps: [
                TrackingStep(status: .placed,     date: Date().addingTimeInterval(-86400 * 2),   title: "Order Placed",  description: "Your order has been received.",           isCompleted: true),
                TrackingStep(status: .shipped, date: nil,                                     title: "Shipped",       description: "Your order has left our boutique.",                isCompleted: false),
                TrackingStep(status: .delivered,  date: nil,                                     title: "Delivered",     description: "Your package has been securely delivered.",                     isCompleted: false)
            ],
            estimatedDelivery: Date().addingTimeInterval(86400 * 3)
        ),
        // Delivered Order
        Order(
            orderNumber: "DIOR-6122-309",
            date: Date().addingTimeInterval(-86400 * 15),
            items: [
                OrderItem(product: products[1], quantity: 1, priceAtPurchase: products[1].price),
                OrderItem(product: products[2], variant: "M",  quantity: 1, priceAtPurchase: products[2].price)
            ],
            subtotal: products[1].price + products[2].price,
            taxes: (products[1].price + products[2].price) * 0.18,
            deliveryFee: 0,
            status: .delivered,
            trackingSteps: [
                TrackingStep(status: .placed,     date: Date().addingTimeInterval(-86400 * 15),   title: "Order Placed", description: "Your order has been received.",       isCompleted: true),
                TrackingStep(status: .shipped, date: Date().addingTimeInterval(-86400 * 14),   title: "Shipped",      description: "Your order has left our boutique.",     isCompleted: true),
                TrackingStep(status: .delivered,  date: Date().addingTimeInterval(-86400 * 12),   title: "Delivered",    description: "Your package has been securely delivered.", isCompleted: true)
            ],
            estimatedDelivery: Date().addingTimeInterval(-86400 * 12)
        ),
    ]
}
