//  OrdersManager.swift
//  User-Side-App
//  App-level observable store for all orders placed in LUXE.
//  Shared via environment so ProfileView, OrdersView, and
//  OrderSuccessView all see the same live data.

import SwiftUI
import Supabase

@Observable
class OrdersManager {

    // Remote synced orders
    var orders: [Order] = []
    var isLoading: Bool = false

    private var channel: RealtimeChannelV2?
    private var listeningTask: Task<Void, Never>?

    // MARK: - Remote Sync

    func loadOrders(userId: UUID) async {
        startListening(userId: userId)

        isLoading = true
        print(" Loading orders for user \(userId)")
        isLoading = true
        do {
            let dtos = try await SyncManager.shared.fetchOrders(userId: userId)
            self.orders = dtos.map { dto in
            // DEBUG: Log each fetched order number
            print(" Fetched order: \(dto.order_number) with status \(dto.status)")
                // Map DTO items to OrderItem
                let orderItems = (dto.customer_order_items ?? []).map { itemDto in
                    // Create a snapshot product from the DTO data
                    let snapshotProduct = Product(
                        id: itemDto.product_id,
                        name: itemDto.product_name,
                        brand: "DIOR", // Can be expanded to store brand in DB if needed
                        price: itemDto.price_at_purchase,
                        originalPrice: nil,
                        imageName: "",
                        imageURL: itemDto.product_image_url,
                        category: "Luxury",
                        isNew: false,
                        rating: 5.0,
                        isFeatured: false,
                        description: ""
                    )

                    return OrderItem(
                        id: itemDto.id,
                        product: snapshotProduct,
                        variant: itemDto.variant,
                        quantity: itemDto.quantity,
                        priceAtPurchase: itemDto.price_at_purchase
                    )
                }

                // Handle high-precision Supabase dates
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                let creationDate = formatter.date(from: dto.created_at ?? "") ??
                                   ISO8601DateFormatter().date(from: dto.created_at ?? "") ?? Date()

                let currentStatus = OrderStatus.from(string: dto.status)

                var generatedSteps: [TrackingStep] = [
                    TrackingStep(status: .placed, date: creationDate, title: "Order Placed", description: "Your order has been placed successfully.", isCompleted: true)
                ]

                if currentStatus == .cancelled {
                    generatedSteps.append(
                        TrackingStep(status: .cancelled, date: Calendar.current.date(byAdding: .hour, value: 1, to: creationDate), title: "Order Cancelled", description: "Your order was cancelled.", isCompleted: true)
                    )
                } else {
                    let isShipped = currentStatus == .shipped || currentStatus == .delivered
                    let isDelivered = currentStatus == .delivered

                    generatedSteps.append(
                        TrackingStep(
                            status: .shipped,
                            date: isShipped ? Calendar.current.date(byAdding: .day, value: 1, to: creationDate) : nil,
                            title: "Shipped",
                            description: "Your order has left our boutique.",
                            isCompleted: isShipped
                        )
                    )

                    generatedSteps.append(
                        TrackingStep(
                            status: .delivered,
                            date: isDelivered ? Calendar.current.date(byAdding: .day, value: 3, to: creationDate) : nil,
                            title: "Delivered",
                            description: "Your package has been securely delivered.",
                            isCompleted: isDelivered
                        )
                    )
                }

                // Map DTO to Order
                return Order(
                    id: dto.id,
                    orderNumber: dto.order_number,
                    date: creationDate,
                    items: orderItems,
                    subtotal: dto.subtotal,
                    taxes: dto.taxes,
                    deliveryFee: dto.delivery_fee,
                    discount: dto.discount_amount ?? 0,
                    status: currentStatus,
                    trackingSteps: generatedSteps,
                    estimatedDelivery: formatter.date(from: dto.estimated_delivery ?? "") ??
                                       ISO8601DateFormatter().date(from: dto.estimated_delivery ?? ""),
                    offer_id: dto.offer_id
                )
            }
        } catch {
            print("Failed to load orders: \(error)")
        }
        isLoading = false
        print(" Finished loading orders  total: \(orders.count)")
    }

    private func startListening(userId: UUID) {
        guard channel == nil else { return }

        let client = SupabaseManager.shared.client
        let newChannel = client.channel("orders_channel_\(userId.uuidString)")
        self.channel = newChannel

        let updates = newChannel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "customer_orders",
            filter: "user_id=eq.\(userId.uuidString)"
        )

        listeningTask = Task {
            await newChannel.subscribe()

            for await _ in updates {
                print(" Realtime update: customer_orders changed. Reloading...")
                await self.loadOrders(userId: userId)
            }
        }
    }

    // MARK: - Computed stats

    var totalOrders: Int {
        orders.count
    }

    var totalSpend: Double {
        orders
            .filter { $0.status != .cancelled }
            .reduce(0) { $0 + $1.finalTotal }
    }

    // MARK: - Filtered lists

    var activeOrders: [Order] {
        orders.filter { $0.status.isActive }.sorted { $0.date > $1.date }
    }

    var pastOrders: [Order] {
        orders.filter { !$0.status.isActive }.sorted { $0.date > $1.date }
    }

    // MARK: - Place Order

    func placeOrder(from cartItems: [CartItem],
                    userId: UUID,
                    redeemedPoints: Int = 0,
                    offerDiscount: Double = 0.0,
                    offerId: UUID? = nil,
                    regionTaxAmount: Double = 0.0,   // Calculated admin region tax per category
                    shippingAddress: String,
                    paymentMethod: String,
                    storeId: UUID) async throws {
        print(" Placing order for user \(userId) with \(cartItems.count) items")
        guard !cartItems.isEmpty else { return }

        let subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        let discount = Double(redeemedPoints) + offerDiscount // 1 point = 1 INR + Offer discount
        let taxableBase = max(0.0, subtotal - discount)
        let taxes    = (taxableBase * 0.18) + regionTaxAmount  // 18% Tax + Region Tax
        let deliveryFee = 0.0
        let orderNumber = generateOrderNumber()

        // Disable points earning per user request
        let earnedPoints = 0

        // Calculate ETA (e.g., 4 days from now)
        let etaDate = Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let etaString = formatter.string(from: etaDate)

        // Prepare Order DTO
        let orderInsert = OrderInsertDTO(
            user_id: userId,
            order_number: orderNumber,
            status: "placed",
            subtotal: subtotal,
            taxes: taxes,
            delivery_fee: deliveryFee,
            shipping_address: shippingAddress,
            payment_method: paymentMethod,
            estimated_delivery: etaString,
            points_earned: earnedPoints,
            points_redeemed: redeemedPoints,
            discount_amount: discount,
            offer_id: offerId
        )

        // Prepare Item DTOs
        let itemInserts = cartItems.map { item in
            OrderItemInsertDTO(
                order_id: UUID(), // Placeholder, SyncManager replaces this
                product_id: item.product.id,
                variant: item.variant,
                quantity: item.quantity,
                price_at_purchase: item.product.price,
                product_name: item.product.name,
                product_image_url: item.product.imageURL
            )
        }

        // Sync to Supabase with RETRY LOGIC for network errors
        var attempts = 0
        let maxAttempts = 3
        var lastError: Error?

        while attempts < maxAttempts {
            attempts += 1
            do {
                try await SyncManager.shared.processCheckout(
                    order: orderInsert,
                    items: itemInserts,
                    pointsEarned: earnedPoints,
                    pointsRedeemed: redeemedPoints,
                    storeId: storeId
                )
                print(" Order RPC succeeded on attempt \(attempts)")
                lastError = nil
                break
            } catch {
                lastError = error
                print(" Order attempt \(attempts) failed: \(error)")

                // Only retry if it's a network error (like "connection lost")
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    print(" Retrying due to network error...")
                    try? await Task.sleep(for: .seconds(Double(attempts) * 1.5)) // Exponential backoff
                    continue
                } else {
                    // Database error or other logic error - don't retry, just throw
                    throw error
                }
            }
        }

        if let error = lastError {
            throw error
        }

        // Reload local list
        await loadOrders(userId: userId)
        print(" Reloaded orders after placement")
    }

    // MARK: - Cancel

    enum OrderCancelError: Error {
        case alreadyShipped
        case alreadyDelivered
        case notFound
    }

    /// Performs a live status check before cancelling.
    /// Throws `OrderCancelError.alreadyShipped` if the admin already marked the order as shipped.
    func cancelOrder(_ orderID: UUID) async throws {
        // 1. Live status check  catches the race window where admin shipped it
        //    while the user still had the "Cancel" button visible from a stale snapshot.
        let liveStatus = try await SyncManager.shared.fetchOrderStatus(orderId: orderID)

        switch liveStatus {
        case "shipped":
            throw OrderCancelError.alreadyShipped
        case "delivered":
            throw OrderCancelError.alreadyDelivered
        case .none:
            throw OrderCancelError.notFound
        default:
            break // "placed" or anything else  safe to cancel
        }

        // 2. Optimistic UI update
        guard let index = orders.firstIndex(where: { $0.id == orderID }) else { return }
        withAnimation {
            orders[index].status = .cancelled
        }

        // 3. Push update to backend
        do {
            try await SyncManager.shared.cancelOrder(orderId: orderID)
            print(" Successfully cancelled order in database")
        } catch {
            // Rollback optimistic update on failure
            withAnimation {
                orders[index].status = .placed
            }
            print(" Failed to cancel order in database: \(error)")
            throw error
        }
    }

    // MARK: - Razorpay Integration

    struct RazorpayOrderResponse: Codable {
        let order_id: String
    }

    func fetchRazorpayOrderID(amount: Double) async throws -> String {
        // Hack for Test Mode: Razorpay's test environment blocks large transactions.
        // Round to 2 decimal places just in case, though the Edge Function does it too
        let roundedAmount = (amount * 100).rounded() / 100

        let body: [String: Double] = [
            "amount": roundedAmount
        ]

        print(" Invoking create-razorpay-order for amount: \(roundedAmount)")

        // Call Supabase Edge Function and decode response directly
        // Restoring 'options' based syntax for compatibility with the project's library version
        let response: RazorpayOrderResponse = try await SupabaseManager.shared.client.functions.invoke(
            "create-razorpay-order",
            options: .init(body: body)
        )

        return response.order_id
    }

    // MARK: - Helpers

    private func generateOrderNumber() -> String {
        let random1 = Int.random(in: 1000...9999)
        let random2 = Int.random(in: 100...999)
        return "DIOR-\(random1)-\(random2)"
    }
}
