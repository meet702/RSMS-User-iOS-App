//  OrderSuccessView.swift
//  User-Side-App
//  LUXE Order Confirmation  Post-purchase celebration

import SwiftUI

struct OrderSuccessView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(NavigationManager.self) private var navManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil
    var purchasedItems: [CartItem] = []

    @State private var animateIcon = false
    @State private var showText = false
    @State private var showReviewSheet = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Animated Success Icon
                ZStack {
                    Circle()
                        .stroke(AppColors.gold.opacity(0.2), lineWidth: 1)
                        .frame(width: 140, height: 140)

                    Circle()
                        .fill(LinearGradient.goldSubtle)
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateIcon ? 1 : 0.8)
                        .opacity(animateIcon ? 1 : 0)

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .opacity(animateIcon ? 1 : 0)
                }

                VStack(spacing: 16) {
                    Text("PURCHASE COMPLETE")
                        .font(.title2)
                        .fontWeight(.bold)
                        .tracking(4)
                        .foregroundStyle(AppColors.pureWhite)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)

                    Text("Your luxury items are being prepared for shipment. A confirmation email has been sent to your registered email.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.grayLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                }

                Spacer()

                // Back to Shop Button
                Button(action: { handleBackToShop() }) {
                    Text("BACK TO SHOP")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(LinearGradient.goldSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.2)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showText = true
            }
        }
        .sheet(isPresented: $showReviewSheet, onDismiss: {
            // After review sheet is dismissed (submit or skip), finalize
            finalizePurchase()
        }) {
            PostPurchaseReviewSheet(
                purchasedItems: purchasedItems,
                userId: userManager.supabaseUserId,
                userName: userManager.currentUser?.firstName ?? "Valued Customer"
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func handleBackToShop() {
        if !purchasedItems.isEmpty {
            // Show review prompt before leaving
            showReviewSheet = true
        } else {
            finalizePurchase()
        }
    }

    private func finalizePurchase() {
        cartManager.clearCart()
        navManager.selectedTab = .orders
        onComplete?()
        dismiss()
    }
}

// MARK: - Post Purchase Review Sheet

struct PostPurchaseReviewSheet: View {
    let purchasedItems: [CartItem]
    let userId: UUID?
    let userName: String
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product? = nil
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Prompt message
                        VStack(spacing: 8) {
                            Image(systemName: "star.bubble")
                                .font(.system(size: 36))
                                .foregroundStyle(AppColors.gold)

                            Text("How was your experience?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.pureWhite)

                            Text("Your feedback helps others make better choices.")
                                .font(.caption)
                                .foregroundStyle(AppColors.grayLight)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        if submitted {
                            // Thank you state
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppColors.gold)
                                Text("Thank you for your review!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppColors.pureWhite)
                            }
                            .padding(.vertical, 30)
                            .transition(.opacity)
                        } else {
                            // Product selection (if multiple items)
                            if purchasedItems.count > 1 && selectedProduct == nil {
                                productSelectionList
                            }

                            // Review form (after product selected or single item)
                            if let product = selectedProduct ?? (purchasedItems.count == 1 ? purchasedItems.first?.product : nil) {
                                reviewForm(for: product)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LEAVE A REVIEW")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tracking(3)
                        .foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(submitted ? "Done" : "Skip") { dismiss() }
                        .foregroundStyle(AppColors.grayLight)
                }
            }
        }
    }

    // MARK: - Product Selection

    private var productSelectionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SELECT A PRODUCT TO REVIEW")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColors.grayLight)

            ForEach(purchasedItems) { item in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedProduct = item.product
                    }
                } label: {
                    HStack(spacing: 12) {
                        AsyncProductImage(product: item.product, contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.pureWhite)
                                .lineLimit(1)
                            Text(item.product.brand)
                                .font(.caption2)
                                .foregroundStyle(AppColors.grayLight)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(AppColors.gold.opacity(0.6))
                    }
                    .padding(12)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Review Form

    private func reviewForm(for product: Product) -> some View {
        VStack(spacing: 20) {
            // Product info header
            HStack(spacing: 14) {
                AsyncProductImage(product: product, contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.brand)
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(AppColors.gold)
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                        .lineLimit(2)
                }
                Spacer()

                // Change product button (if multiple items)
                if purchasedItems.count > 1 {
                    Button {
                        withAnimation { selectedProduct = nil }
                    } label: {
                        Text("Change")
                            .font(.caption2)
                            .foregroundStyle(AppColors.gold)
                    }
                }
            }

            // Star rating
            VStack(spacing: 8) {
                Text("TAP TO RATE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.grayLight)

                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: { rating = star }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title)
                                .foregroundStyle(star <= rating ? AppColors.gold : AppColors.grayDark)
                        }
                    }
                }
            }

            // Optional comment
            VStack(alignment: .leading, spacing: 8) {
                Text("COMMENT (OPTIONAL)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.grayLight)

                TextField("Share your thoughts...", text: $comment, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(12)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
                    .foregroundStyle(AppColors.pureWhite)
            }

            // Submit button
            Button {
                submitReview(for: product)
            } label: {
                if isSubmitting {
                    ProgressView().tint(AppColors.background)
                } else {
                    Text("SUBMIT REVIEW")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1)
                }
            }
            .foregroundStyle(AppColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.gold)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isSubmitting)
        }
        .padding(20)
        .background(AppColors.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Submit

    private func submitReview(for product: Product) {
        guard let userId else { return }
        isSubmitting = true

        let review = ReviewDTO(
            id: nil,
            product_id: product.id,
            user_id: userId,
            user_name: userName,
            rating: rating,
            comment: comment.isEmpty ? nil : comment,
            created_at: nil
        )

        Task {
            do {
                try await SyncManager.shared.addReview(review: review)
                withAnimation {
                    submitted = true
                }
                // Auto-dismiss after a moment
                try? await Task.sleep(for: .seconds(1.5))
                dismiss()
            } catch {
                print(" Failed to submit review: \(error)")
            }
            isSubmitting = false
        }
    }
}

#Preview {
    OrderSuccessView()
        .environment(NavigationManager())
        .withLuxePreviewEnvironment()
}
