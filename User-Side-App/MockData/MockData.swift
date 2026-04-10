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
        Category(name: "Watches", icon: "clock.fill", productCount: 42),
        Category(name: "Jewelry", icon: "sparkles", productCount: 38),
        Category(name: "Fashion", icon: "tshirt.fill", productCount: 65),
        Category(name: "Handbags", icon: "bag.fill", productCount: 29),
        Category(name: "Shoes", icon: "shoe.fill", productCount: 34),
        Category(name: "Fragrances", icon: "drop.fill", productCount: 21),
        Category(name: "Accessories", icon: "eyeglasses", productCount: 47),
        Category(name: "Sunglasses", icon: "sun.max.fill", productCount: 18),
    ]
    
    // MARK: - Products
    
    static let products: [Product] = [
        // Watches
        Product(
            name: "Submariner Date",
            brand: "ROLEX",
            price: 1_250_000,
            originalPrice: 1_450_000,
            imageName: "clock.fill",
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
            imageName: "clock.fill",
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
            imageName: "clock.fill",
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
            imageName: "circle.circle.fill",
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
            imageName: "sparkle",
            category: "Jewelry",
            rating: 4.6,
            isFeatured: true,
            description: "A symbol of strength and joy. 18K rose gold with brilliant diamonds."
        ),
        Product(
            name: "B.zero1 Ring",
            brand: "BVLGARI",
            price: 245_000,
            imageName: "circle.circle.fill",
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
            imageName: "bag.fill",
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
            imageName: "drop.fill",
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
            icon: "sun.max.fill",
            gradientAngle: 45
        ),
        PromoBanner(
            title: "Exclusive 20% Off",
            subtitle: "On Selected Luxury Watches",
            ctaText: "EXPLORE",
            icon: "clock.fill",
            gradientAngle: 135
        ),
        PromoBanner(
            title: "Royal Collection",
            subtitle: "Handcrafted Jewelry Masterpieces",
            ctaText: "DISCOVER",
            icon: "crown.fill",
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
}

