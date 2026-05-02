//
//  ProductReviewsView.swift
//  User-Side-App
//

import SwiftUI

struct ProductReviewsView: View {
    let productId: UUID
    @Binding var reviews: [ReviewDTO]
    @Environment(UserManager.self) private var userManager
    
    @State private var isLoading = false
    @State private var showAddReview = false
    @State private var hasPurchased = false
    @State private var checkingPurchase = true
    
    @State private var newRating: Int = 5
    @State private var newComment: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CUSTOMER REVIEWS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppColors.gold)
                    
                    Text("\(reviews.count) Reviews")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                }
                
                Spacer()
                
                if checkingPurchase {
                    ProgressView()
                        .tint(AppColors.gold)
                        .scaleEffect(0.7)
                } else if hasPurchased {
                    Button(action: { withAnimation(.spring(response: 0.4)) { showAddReview.toggle() } }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("ADD REVIEW")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.gold)
                        .clipShape(Capsule())
                    }
                }
            }
            
            if showAddReview {
                addReviewForm
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if isLoading {
                ProgressView()
                    .tint(AppColors.gold)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if reviews.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.bubble")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.grayDark)
                    Text("No reviews yet. Be the first to share your experience.")
                        .font(.caption)
                        .foregroundStyle(AppColors.grayLight)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 20) {
                    ForEach(reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
        .task {
            await checkPurchaseStatus()
        }
    }
    
    private var addReviewForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RATE THIS PRODUCT")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.gold)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: { newRating = star }) {
                        Image(systemName: star <= newRating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(star <= newRating ? AppColors.gold : AppColors.grayDark)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR COMMENT (OPTIONAL)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.grayLight)
                
                TextField("Share your thoughts...", text: $newComment, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(AppColors.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.grayDark.opacity(0.3), lineWidth: 1))
                    .foregroundStyle(AppColors.pureWhite)
            }
            
            Button(action: { submitReview() }) {
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
    
    private func checkPurchaseStatus() async {
        guard let userId = userManager.supabaseUserId else {
            checkingPurchase = false
            return
        }
        do {
            hasPurchased = try await SyncManager.shared.hasUserPurchasedProduct(userId: userId, productId: productId)
        } catch {
            print("❌ Failed to check purchase status: \(error)")
            hasPurchased = false
        }
        checkingPurchase = false
    }
    
    private func loadReviews() async {
        isLoading = true
        do {
            self.reviews = try await SyncManager.shared.fetchReviews(productId: productId)
        } catch {
            print("❌ Failed to load reviews: \(error)")
        }
        isLoading = false
    }
    
    private func submitReview() {
        guard let userId = userManager.supabaseUserId else { return }
        isSubmitting = true
        
        let review = ReviewDTO(
            id: nil,
            product_id: productId,
            user_id: userId,
            user_name: userManager.currentUser?.firstName ?? "Valued Customer",
            rating: newRating,
            comment: newComment.isEmpty ? nil : newComment,
            created_at: nil
        )
        
        Task {
            do {
                try await SyncManager.shared.addReview(review: review)
                await loadReviews()
                withAnimation {
                    showAddReview = false
                    newComment = ""
                    newRating = 5
                }
            } catch {
                print("❌ Failed to submit review: \(error)")
            }
            isSubmitting = false
        }
    }
}

struct ReviewRow: View {
    let review: ReviewDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.user_name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.pureWhite)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundStyle(star <= review.rating ? AppColors.gold : AppColors.grayDark)
                        }
                    }
                }
                
                Spacer()
                
                if let dateStr = review.created_at {
                    Text(formatDate(dateStr))
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.grayLight)
                }
            }
            
            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.grayLight)
                    .lineSpacing(4)
            }
            
            Rectangle()
                .fill(AppColors.grayDark.opacity(0.3))
                .frame(height: 0.5)
        }
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr) else {
            return ""
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
}
