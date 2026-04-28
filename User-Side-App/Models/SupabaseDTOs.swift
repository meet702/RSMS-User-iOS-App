//
//  SupabaseDTOs.swift
//  User-Side-App
//
//  Supabase Data Transfer Objects (DTOs) for the DIOR Customer App.
//  Maps exactly to the Supabase PG schema.
//

import Foundation

// MARK: - Product DTOs

/// Matches the `products` table in Supabase (RSMS retail schema)
struct ProductDTO: Codable, Sendable {
    let id: UUID
    let sku: String
    let name: String
    let description: String?
    var base_price: Double
    let category: String?
    let image_url: String?
    let created_at: String?
    
    func toProduct() -> Product {
        Product(
            id: id,
            name: name,
            brand: "DIOR",
            price: base_price,
            originalPrice: nil,
            imageName: "",
            imageURL: image_url,
            category: category ?? "Uncategorized",
            isNew: false,
            rating: 4.5,
            isFeatured: false,
            description: description ?? ""
        )
    }
}

/// Matches the `categories` table in Supabase (RSMS retail schema)
struct CategoryDTO: Codable, Sendable {
    let id: UUID
    let name: String
    
    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            icon: Self.iconFor(name),
            imageURL: nil,
            productCount: 0
        )
    }
    
    private static func iconFor(_ name: String) -> String {
        let n = name.lowercased()
        switch n {
        case _ where n.contains("watch"):     return "applewatch"
        case _ where n.contains("jewel"):     return "sparkles"
        case _ where n.contains("fashion"), _ where n.contains("clothing"), _ where n.contains("apparel"), _ where n.contains("wear"):   return "tshirt.fill"
        case _ where n.contains("handbag"), _ where n.contains("bag"): return "bag.fill"
        case _ where n.contains("shoe"), _ where n.contains("footwear"):      return "shoe.fill"
        case _ where n.contains("fragrance"), _ where n.contains("perfume"): return "drop.fill"
        case _ where n.contains("accessor"):  return "sunglasses"
        case _ where n.contains("beauty"), _ where n.contains("makeup"), _ where n.contains("skin"): return "sparkles"
        case _ where n.contains("home"), _ where n.contains("lifestyle"): return "house.fill"
        case _ where n.contains("gift"): return "gift.fill"
        default: return "tag.fill"
        }
    }
}

// MARK: - Customer DTOs

/// Matches the `customer_profiles` table
struct ProfileDTO: Codable, Sendable {
    let id: UUID
    var first_name: String
    var last_name: String
    var email: String
    var phone: String?
    var tier: String
    var loyalty_points: Int
    var avatar_url: String?
}

/// Matches the `customer_wishlist` table
struct WishlistItemDTO: Codable, Sendable {
    let id: UUID?
    let user_id: UUID
    let product_id: UUID
    let created_at: String?
    
    // Joined product data
    let products: ProductDTO?
}

/// Matches the `customer_cart` table
struct CartItemDTO: Codable, Sendable {
    let id: UUID?
    let user_id: UUID
    let product_id: UUID
    let variant: String?
    let quantity: Int
    let created_at: String?
    
    // Joined product data
    var products: ProductDTO?
}

// MARK: - Order DTOs

/// For inserting into `customer_orders`
struct OrderInsertDTO: Codable, Sendable {
    let user_id: UUID
    let order_number: String
    let status: String
    let subtotal: Double
    let taxes: Double
    let delivery_fee: Double
    let shipping_address: String?
    let payment_method: String?
    let estimated_delivery: String?
    
    // Loyalty Points
    let points_earned: Int
    let points_redeemed: Int
    let discount_amount: Double
}

/// For inserting into `customer_order_items`
struct OrderItemInsertDTO: Codable, Sendable {
    let order_id: UUID
    let product_id: UUID
    let variant: String?
    let quantity: Int
    let price_at_purchase: Double
    let product_name: String
    let product_image_url: String?
}

/// Matches `customer_orders` for reads
struct OrderDTO: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let order_number: String
    let status: String
    let subtotal: Double
    let taxes: Double
    let delivery_fee: Double
    let shipping_address: String?
    let payment_method: String?
    let estimated_delivery: String?
    let created_at: String?
    
    // Loyalty Points
    let points_earned: Int?
    let points_redeemed: Int?
    let discount_amount: Double?
    
    // Joined items
    let customer_order_items: [OrderItemDTO]?
}

struct OrderItemDTO: Codable, Sendable {
    let id: UUID
    let product_id: UUID
    let variant: String?
    let quantity: Int
    let price_at_purchase: Double
    let product_name: String
    let product_image_url: String?
}

// MARK: - Notification DTO

struct NotificationDTO: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let title: String
    let message: String
    let icon: String?
    let is_read: Bool
    let created_at: String?
}

// MARK: - Address DTO

struct AddressDTO: Codable, Sendable, Identifiable {
    let id: UUID
    let user_id: UUID
    let label: String?
    
    // Structured Fields
    let building_name: String?
    let area_street: String?
    let landmark: String?
    let city: String
    let state: String?
    let pincode: String?
    let country: String?
    
    let full_address: String
    let is_default: Bool
    let created_at: String?
}

// MARK: - Offer DTO

struct OfferDTO: Codable, Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let discount_type: String?
    let discount_value: Double?
    let status: String?
    let start_date: String?
    let end_date: String?
    let coupon_code: String?
    let usage_limit: Int?
    let is_paused: Bool?
    let is_stackable: Bool?
    let store_id: UUID?
}

// MARK: - Appointment DTO

struct AppointmentDTO: Codable, Sendable {
    let user_id: UUID
    let appointment_date: String
    let notes: String?
    let status: String
}

// MARK: - Store DTO

struct StoreDTO: Codable, Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let city: String
}
