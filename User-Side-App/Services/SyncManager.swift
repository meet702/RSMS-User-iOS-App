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
        return [
            Category(name: "Jewellery", icon: "sparkles"),
            Category(name: "Watches", icon: "clock.fill"),
            Category(name: "Leather Goods", icon: "bag.fill"),
            Category(name: "Couture", icon: "tshirt.fill"),
            Category(name: "Accessories", icon: "eyeglasses"),
            Category(name: "Fragrance", icon: "wind"),
            Category(name: "Eyewear", icon: "eyeglasses"),
            Category(name: "Other", icon: "tag.fill")
        ]
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
    
    /// Fetches admin-configured regional tax rules.
    func fetchTaxRules() async throws -> [TaxRuleDTO] {
        let rules: [TaxRuleDTO] = try await client
            .from("tax_rules")
            .select()
            .execute()
            .value
        return rules
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
    
    /// Fetches only the `status` field for a single order — lightweight live-check before cancel.
    func fetchOrderStatus(orderId: UUID) async throws -> String? {
        struct StatusOnly: Decodable { let status: String }
        let rows: [StatusOnly] = try await client
            .from("customer_orders")
            .select("status")
            .eq("id", value: orderId)
            .limit(1)
            .execute()
            .value
        return rows.first?.status
    }

    func cancelOrder(orderId: UUID) async throws {
        // First, delete related transactions if any
        try? await client
            .from("transactions")
            .delete()
            .eq("order_id", value: orderId)
            .execute()
            
        // Delete related order items to satisfy foreign key constraints
        try await client
            .from("customer_order_items")
            .delete()
            .eq("order_id", value: orderId)
            .execute()
            
        // Finally, delete the order from customer_orders table
        try await client
            .from("customer_orders")
            .delete()
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
            let total_amount: Double
            let offer_id: UUID?
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
            discount_amount: order.discount_amount,
            total_amount: order.subtotal + order.taxes + order.delivery_fee - order.discount_amount,
            offer_id: order.offer_id
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
    
    func bookAppointment(dto: AppointmentDTO, profile: ProfileDTO? = nil) async throws {
        // 1. Standard Write (for Customer's "My Appointments")
        // We use a specific map here to avoid sending new fields (title/type) 
        // to the legacy customer_appointments table which might not have them.
        struct LegacyAppointmentInsert: Encodable {
            let user_id: UUID
            let appointment_date: String
            let notes: String?
            let status: String
            let store_id: UUID?
        }
        
        let customerData = LegacyAppointmentInsert(
            user_id: dto.user_id,
            appointment_date: dto.appointment_date,
            notes: dto.notes,
            status: dto.status,
            store_id: dto.store_id
        )
        
        do {
            try await client
                .from("customer_appointments")
                .insert(customerData)
                .execute()
            print("✅ Standard Appointment created")
        } catch {
            print("⚠️ Standard Appointment failed (likely missing columns): \(error.localizedDescription)")
            // We continue anyway so the VIP sync can still happen
        }
            
        // 2. VIP Cross-Sync (for Staff App "VIP & Events" Tab)
        if let profile = profile, let storeId = dto.store_id {
            try await syncToVIPSystem(dto: dto, profile: profile, storeId: storeId)
        }
    }
    
    /// Creates a VIP Appointment entry for the Staff App.
    private func syncToVIPSystem(dto: AppointmentDTO, profile: ProfileDTO, storeId: UUID) async throws {
        print("📡 Syncing to VIP System: User=\(profile.id), Store=\(storeId)")
        
        // Create the VIP Appointment entry
        struct VIPAppointmentInsert: Encodable {
            let guest_id: UUID
            let boutique_id: UUID
            let title: String?
            let appointment_date: String
            let type: String
            let status: String
            let notes: String?
        }
        
        let apptData = VIPAppointmentInsert(
            guest_id: profile.id,
            boutique_id: storeId,
            title: dto.title ?? "Boutique Visit",
            appointment_date: dto.appointment_date,
            type: dto.type,
            status: "scheduled",
            notes: dto.notes
        )
        
        do {
            try await client
                .from("vip_appointments")
                .insert(apptData)
                .execute()
            print("✅ VIP Appointment synced")
        } catch {
            print("❌ VIP Appointment sync failed: \(error.localizedDescription)")
            throw error
        }
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
    
    /// Check if a user has purchased a specific product (any completed order containing the product)
    func hasUserPurchasedProduct(userId: UUID, productId: UUID) async throws -> Bool {
        struct OrderItemCheck: Decodable {
            let id: UUID
        }
        
        // Query order items where the order belongs to this user and contains this product
        let items: [OrderItemCheck] = try await client
            .from("customer_order_items")
            .select("id, customer_orders!inner(user_id)")
            .eq("product_id", value: productId)
            .eq("customer_orders.user_id", value: userId)
            .limit(1)
            .execute()
            .value
        
        return !items.isEmpty
    }
}
