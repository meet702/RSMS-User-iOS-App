//
//  MockData.swift
//  User-Side-App
//
//  Sample data for LUXE — luxury products, categories & banners
//

import Foundation

enum MockData {
    
    // MARK: - Categories
    
    static let categories: [Category] = [
        Category(name: "Watches", icon: "watch_submariner", productCount: 42),
        Category(name: "Jewelry", icon: "jewelry_bracelet", productCount: 38),
        Category(name: "Fashion", icon: "fashion_couture", productCount: 65),
        Category(name: "Handbags", icon: "handbag_classic", productCount: 29),
        Category(name: "Shoes", icon: "handbag_classic", productCount: 34),
        Category(name: "Fragrances", icon: "fragrance_luxury", productCount: 21),
        Category(name: "Accessories", icon: "handbag_classic", productCount: 47),
        Category(name: "Sunglasses", icon: "handbag_classic", productCount: 18),
    ]
    
    // MARK: - Products
    
    static let products: [Product] = [
        // Watches
        Product(
            name: "Submariner Date",
            brand: "ROLEX",
            price: 1_250_000,
            originalPrice: 1_450_000,
            imageName: "watch_submariner",
            category: "Watches",
            isNew: true,
            rating: 4.9,
            isFeatured: true,
            description: "The reference among divers' watches. Water-resistant to 300 metres with a unidirectional rotatable bezel."
        ),
        Product(
            name: "Seamaster Aqua Terra",
            brand: "OMEGA",
            price: 485_000,
            imageName: "watch_submariner",
            category: "Watches",
            rating: 4.8,
            isFeatured: true,
            description: "A masterpiece of elegance and innovation. Co-Axial Master Chronometer movement."
        ),
        Product(
            name: "Carrera Chronograph",
            brand: "TAG HEUER",
            price: 325_000,
            originalPrice: 375_000,
            imageName: "watch_submariner",
            category: "Watches",
            isNew: true,
            rating: 4.7,
            description: "Racing heritage meets modern sophistication. Automatic chronograph with 80-hour power reserve."
        ),
        
        // Jewelry
        Product(
            name: "Love Bracelet",
            brand: "CARTIER",
            price: 680_000,
            imageName: "jewelry_bracelet",
            category: "Jewelry",
            isNew: true,
            rating: 4.9,
            isFeatured: true,
            description: "An icon of love. 18K gold bracelet with the unmistakable screw motif."
        ),
        Product(
            name: "T Smile Pendant",
            brand: "TIFFANY & CO.",
            price: 185_000,
            originalPrice: 215_000,
            imageName: "jewelry_bracelet",
            category: "Jewelry",
            rating: 4.6,
            isFeatured: true,
            description: "A symbol of strength and joy. 18K rose gold with brilliant diamonds."
        ),
        Product(
            name: "B.zero1 Ring",
            brand: "BVLGARI",
            price: 245_000,
            imageName: "jewelry_bracelet",
            category: "Jewelry",
            isNew: true,
            rating: 4.8,
            description: "Inspired by the Colosseum. Spiral design in 18K white gold."
        ),
        
        // Fashion
        Product(
            name: "Ace Leather Sneakers",
            brand: "GUCCI",
            price: 72_000,
            originalPrice: 85_000,
            imageName: "shoe.fill",
            category: "Fashion",
            rating: 4.5,
            isFeatured: true,
            description: "Clean, classic and unmistakably Gucci. Italian leather with the iconic Web stripe."
        ),
        Product(
            name: "Re-Nylon Jacket",
            brand: "PRADA",
            price: 195_000,
            imageName: "tshirt.fill",
            category: "Fashion",
            isNew: true,
            rating: 4.7,
            description: "Sustainable luxury redefined. Crafted from regenerated nylon with triangle logo."
        ),
        
        // Handbags
        Product(
            name: "Neverfull MM",
            brand: "LOUIS VUITTON",
            price: 165_000,
            imageName: "bag.fill",
            category: "Handbags",
            rating: 4.8,
            isFeatured: true,
            description: "The iconic tote in Monogram canvas. Spacious, versatile, and eternally elegant."
        ),
        Product(
            name: "Classic Flap Bag",
            brand: "CHANEL",
            price: 875_000,
            imageName: "handbag_classic",
            category: "Handbags",
            isNew: true,
            rating: 5.0,
            isFeatured: true,
            description: "The pinnacle of timeless luxury. Lambskin with gold-tone hardware and interlocking CC clasp."
        ),
        
        // Fragrances
        Product(
            name: "Oud Wood",
            brand: "TOM FORD",
            price: 32_000,
            originalPrice: 38_000,
            imageName: "drop.fill",
            category: "Fragrances",
            rating: 4.6,
            description: "Rare, exotic, and distinctive. A blend of oud wood, sandalwood, and vetiver."
        ),
        Product(
            name: "N°5 Eau de Parfum",
            brand: "CHANEL",
            price: 15_500,
            imageName: "fragrance_luxury",
            category: "Fragrances",
            rating: 4.9,
            isFeatured: true,
            description: "The legendary fragrance. A timeless, feminine scent that defines elegance."
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
        Array(products.shuffled().prefix(8))
    }
    
    // MARK: - Promotional Banners
    
    static let banners: [PromoBanner] = [
        PromoBanner(
            title: "Summer Collection",
            subtitle: "Discover Timeless Elegance",
            ctaText: "SHOP NOW",
            imageName: "banner_summer",
            gradientAngle: 45
        ),
        PromoBanner(
            title: "Exclusive 20% Off",
            subtitle: "On Selected Luxury Watches",
            ctaText: "EXPLORE",
            imageName: "banner_watch",
            gradientAngle: 135
        ),
        PromoBanner(
            title: "Royal Collection",
            subtitle: "Handcrafted Jewelry Masterpieces",
            ctaText: "DISCOVER",
            imageName: "jewelry_bracelet",
            gradientAngle: 90
        ),
    ]
    
    // MARK: - Product Variants
    
    static func variants(for product: Product) -> [String] {
        switch product.category {
        case "Watches":
            return ["38mm", "40mm", "42mm", "44mm"]
        case "Jewelry":
            return ["Small", "Medium", "Large"]
        case "Fashion":
            return ["XS", "S", "M", "L", "XL"]
        case "Handbags":
            return ["Mini", "Small", "Medium", "Large"]
        case "Shoes":
            return ["UK 6", "UK 7", "UK 8", "UK 9", "UK 10"]
        case "Fragrances":
            return ["30ml", "50ml", "100ml", "150ml"]
        case "Accessories", "Sunglasses":
            return ["One Size"]
        default:
            return ["Standard"]
        }
    }
    
    // MARK: - Mock Orders
    
    static let orders: [Order] = [
        // Active Order
        Order(
            orderNumber: "ORD-9482-771",
            date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            items: [
                OrderItem(product: products[0], variant: "40mm", quantity: 1, priceAtPurchase: products[0].price)
            ],
            subtotal: products[0].price,
            taxes: products[0].price * 0.18,
            deliveryFee: 0,
            status: .processing,
            trackingSteps: [
                TrackingStep(status: .placed, date: Date().addingTimeInterval(-86400 * 2), title: "Order Placed", description: "Your order has been received.", isCompleted: true),
                TrackingStep(status: .processing, date: Date().addingTimeInterval(-86400 * 1.5), title: "Processing", description: "We are preparing your item for dispatch.", isCompleted: true),
                TrackingStep(status: .dispatched, date: nil, title: "Dispatched", description: "Your item is on the way.", isCompleted: false),
                TrackingStep(status: .delivered, date: nil, title: "Delivered", description: "Estimated delivery.", isCompleted: false)
            ],
            estimatedDelivery: Date().addingTimeInterval(86400 * 3)
        ),
        // Delivered Order
        Order(
            orderNumber: "ORD-6122-309",
            date: Date().addingTimeInterval(-86400 * 15), // 15 days ago
            items: [
                OrderItem(product: products[1], quantity: 1, priceAtPurchase: products[1].price),
                OrderItem(product: products[2], variant: "Medium", quantity: 1, priceAtPurchase: products[2].price)
            ],
            subtotal: products[1].price + products[2].price,
            taxes: (products[1].price + products[2].price) * 0.18,
            deliveryFee: 500,
            status: .delivered,
            trackingSteps: [
                TrackingStep(status: .placed, date: Date().addingTimeInterval(-86400 * 15), title: "Order Placed", description: "Your order has been received.", isCompleted: true),
                TrackingStep(status: .processing, date: Date().addingTimeInterval(-86400 * 14.5), title: "Processing", description: "Item prepared for dispatch.", isCompleted: true),
                TrackingStep(status: .dispatched, date: Date().addingTimeInterval(-86400 * 14), title: "Dispatched", description: "Item handled to courier partner.", isCompleted: true),
                TrackingStep(status: .delivered, date: Date().addingTimeInterval(-86400 * 12), title: "Delivered", description: "Delivered securely to your address.", isCompleted: true)
            ],
            estimatedDelivery: Date().addingTimeInterval(-86400 * 12)
        ),
        // Cancelled Order
        Order(
            orderNumber: "ORD-1093-884",
            date: Date().addingTimeInterval(-86400 * 30),
            items: [
                OrderItem(product: products[6], variant: "One Size", quantity: 1, priceAtPurchase: products[6].price)
            ],
            subtotal: products[6].price,
            taxes: products[6].price * 0.18,
            deliveryFee: 0,
            status: .cancelled,
            trackingSteps: [
                TrackingStep(status: .placed, date: Date().addingTimeInterval(-86400 * 30), title: "Order Placed", description: "Your order has been received.", isCompleted: true),
                TrackingStep(status: .cancelled, date: Date().addingTimeInterval(-86400 * 29.5), title: "Order Cancelled", description: "You cancelled this order.", isCompleted: true)
            ]
        )
    ]
}

