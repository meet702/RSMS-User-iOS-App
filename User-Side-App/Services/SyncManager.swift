//
//  SyncManager.swift
//  User-Side-App
//
//  Centralized Supabase Data Manager for DIOR.
//  Handles all CRUD operations and remote state synchronization.
//

import Foundation
import Supabase

@MainActor
@Observable
class SyncManager {
    static let shared = SyncManager()
    
    // Remote client access
    private var client: SupabaseClient { SupabaseManager.shared.client }
    
    private init() {}
    
    // MARK: - Products & Categories (Public)
    
    func fetchProducts() async throws -> [Product] {
        do {
            let dtos: [ProductDTO] = try await client
                .from("products")
                .select()
                .execute()
                .value
            
            print("✅ SyncManager: Successfully fetched \(dtos.count) products")
            
            return dtos.map { dto in
                var product = dto.toProduct()
                if product.name == "Rose des Vents Bracelet" {
                    product.price = 1.0
                }
                return product
            }
        } catch {
            print("❌ SyncManager (fetchProducts) Error: \(error)")
            throw error
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        let dtos: [CategoryDTO] = try await client
            .from("categories")
            .select()
            .execute()
            .value
        return dtos.map { $0.toCategory() }
    }
    
    // MARK: - Offers Management
    
    func fetchActiveOffers() async throws -> [OfferDTO] {
        let dtos: [OfferDTO] = try await client
            .from("offers")
            .select()
            .execute()
            .value
        return dtos
    }
    
    // MARK: - Stores Management
    
    func fetchStores() async throws -> [StoreDTO] {
        let dtos: [StoreDTO] = try await client
            .from("stores")
            .select("id, name, city")
            .eq("isActive", value: true)
            .execute()
            .value
        return dtos
    }
    
    // MARK: - Profile Management
    
    func fetchProfile(userId: UUID) async throws -> ProfileDTO? {
        let dtos: [ProfileDTO] = try await client
            .from("customer_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        return dtos.first
    }
    
    func upsertProfile(_ profile: ProfileDTO) async throws {
        try await client
            .from("customer_profiles")
            .upsert(profile)
            .execute()
    }
    
    // MARK: - Cart Operations
    
    func fetchCart(userId: UUID) async throws -> [CartItemDTO] {
        let dtos: [CartItemDTO] = try await client
            .from("customer_cart")
            .select("*, products(*)")
            .eq("user_id", value: userId)
            .execute()
            .value
            
        // TEST OVERRIDE: 
        // 1. Make the bracelet ₹1
        // 2. We can't easily change the CartManager's tax logic here, 
        //    but we ensure the DTO reflects the ₹1 price.
        return dtos.map { dto in
            var updatedDto = dto
            if dto.products?.name == "Rose des Vents Bracelet" {
                if var p = dto.products {
                    p.base_price = 1.0
                    updatedDto.products = p
                }
            }
            return updatedDto
        }
    }
    
    func syncAddToCart(userId: UUID, productId: UUID, variant: String?, quantity: Int) async throws {
        print("📡 Syncing to Supabase Cart: User=\(userId), Product=\(productId), Variant=\(variant ?? "nil"), Qty=\(quantity)")
        
        struct CartInsert: Codable {
            let user_id: UUID
            let product_id: UUID
            let variant: String?
            let quantity: Int
        }
        
        let data = CartInsert(user_id: userId, product_id: productId, variant: variant, quantity: quantity)
        
        try await client
            .from("customer_cart")
            .upsert(data, onConflict: "user_id,product_id,variant")
            .execute()
    }
    
    func syncRemoveFromCart(userId: UUID, productId: UUID, variant: String?) async throws {
        // Construct query to delete specific user-product-variant combo
        let query = client
            .from("customer_cart")
            .delete()
            .eq("user_id", value: userId)
            .eq("product_id", value: productId)
            
        if let variant = variant {
            try await query.eq("variant", value: variant).execute()
        } else {
            // Explicitly handle NULL variant to avoid deleting all variants of the product
            try await query.is("variant", value: nil).execute()
        }
    }
    
    func syncClearCart(userId: UUID) async throws {
        try await client
            .from("customer_cart")
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
    
    // MARK: - Wishlist Operations
    
    func fetchWishlist(userId: UUID) async throws -> [Product] {
        let dtos: [WishlistItemDTO] = try await client
            .from("customer_wishlist")
            .select("*, products(*)")
            .eq("user_id", value: userId)
            .execute()
            .value
        return dtos.compactMap { $0.products?.toProduct() }
    }
    
    func syncAddToWishlist(userId: UUID, productId: UUID) async throws {
        let item = ["user_id": userId.uuidString, "product_id": productId.uuidString]
        try await client
            .from("customer_wishlist")
            .insert(item)
            .execute()
    }
    
    func syncRemoveFromWishlist(userId: UUID, productId: UUID) async throws {
        try await client
            .from("customer_wishlist")
            .delete()
            .eq("user_id", value: userId)
            .eq("product_id", value: productId)
            .execute()
    }
    
    // MARK: - Address Book Operations
    
    func fetchAddresses(userId: UUID) async throws -> [AddressDTO] {
        print("📡 SyncManager: Fetching addresses for user: \(userId)")
        let dtos: [AddressDTO] = try await client
            .from("customer_addresses")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
        print("✅ SyncManager: Found \(dtos.count) addresses")
        return dtos
    }
    
    func addAddress(address: AddressDTO) async throws {
        print("📡 SyncManager: Adding new address for user: \(address.user_id)")
        try await client
            .from("customer_addresses")
            .insert(address)
            .execute()
        print("✅ SyncManager: Address added successfully")
    }
    
    func updateAddress(address: AddressDTO) async throws {
        try await client
            .from("customer_addresses")
            .update(address)
            .eq("id", value: address.id)
            .execute()
    }
    
    func deleteAddress(id: UUID) async throws {
        try await client
            .from("customer_addresses")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Order Operations
    
    func fetchOrders(userId: UUID) async throws -> [OrderDTO] {
        try await client
            .from("customer_orders")
            .select("*, customer_order_items(*)")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func cancelOrder(orderId: UUID) async throws {
        struct UpdateStatus: Encodable {
            let status: String
        }
        try await client
            .from("customer_orders")
            .update(UpdateStatus(status: "Cancelled"))
            .eq("id", value: orderId)
            .execute()
    }
    
    private struct LuxeOrderParams: Encodable {
        let p_user_id: UUID
        let p_points_earned: Int
        let p_points_redeemed: Int
        let p_order_payload: OrderDict
        let p_items_payload: [ItemDict]
        let p_store_id: UUID
        
        struct OrderDict: Encodable {
            let order_number: String
            let status: String
            let subtotal: Double
            let taxes: Double
            let delivery_fee: Double
            let shipping_address: String
            let payment_method: String
            let estimated_delivery: String
            let points_earned: Int
            let points_redeemed: Int
            let discount_amount: Double
        }
        
        struct ItemDict: Encodable {
            let product_id: UUID
            let variant: String
            let quantity: Int
            let price_at_purchase: Double
            let product_name: String
            let product_image_url: String
        }
    }

    func processCheckout(order: OrderInsertDTO, items: [OrderItemInsertDTO], pointsEarned: Int, pointsRedeemed: Int, storeId: UUID) async throws {
        // 1. Prepare typed parameters
        let orderDict = LuxeOrderParams.OrderDict(
            order_number: order.order_number,
            status: order.status,
            subtotal: order.subtotal,
            taxes: order.taxes,
            delivery_fee: order.delivery_fee,
            shipping_address: order.shipping_address ?? "Selected Address",
            payment_method: order.payment_method ?? "Razorpay",
            estimated_delivery: order.estimated_delivery ?? "",
            points_earned: order.points_earned,
            points_redeemed: order.points_redeemed,
            discount_amount: order.discount_amount
        )
        
        let itemDicts = items.map { item in
            LuxeOrderParams.ItemDict(
                product_id: item.product_id,
                variant: item.variant ?? "",
                quantity: item.quantity,
                price_at_purchase: item.price_at_purchase,
                product_name: item.product_name,
                product_image_url: item.product_image_url ?? ""
            )
        }
        
        let params = LuxeOrderParams(
            p_user_id: order.user_id,
            p_points_earned: pointsEarned,
            p_points_redeemed: pointsRedeemed,
            p_order_payload: orderDict,
            p_items_payload: itemDicts,
            p_store_id: storeId
        )
        
        // 2. The One-Shot call via typed parameters
        try await client
            .rpc("complete_luxe_order", params: params)
            .execute()
    }
    
    // MARK: - Appointment Operations
    
    func bookAppointment(dto: AppointmentDTO) async throws {
        try await client
            .from("customer_appointments")
            .insert(dto)
            .execute()
    }

    // MARK: - Review Operations
    
    func fetchReviews(productId: UUID) async throws -> [ReviewDTO] {
        let dtos: [ReviewDTO] = try await client
            .from("product_reviews")
            .select()
            .eq("product_id", value: productId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return dtos
    }
    
    func addReview(review: ReviewDTO) async throws {
        try await client
            .from("product_reviews")
            .insert(review)
            .execute()
    }
}
