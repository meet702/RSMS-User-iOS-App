//  ConciergeView.swift
//  User-Side-App
//  Premium Personal Concierge interface for LUXE.
//  Provides a sophisticated chat experience with a dedicated style advisor.

import SwiftUI

struct ConciergeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = MockData.conciergeMessages
    @State private var isTyping = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            conciergeHeader

            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            typingIndicator
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .padding(20)
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input Area
            messageInputBar
        }
        .background(AppColors.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Components

    private var conciergeHeader: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.gold)
            }

            ZStack {
                Circle()
                    .fill(LinearGradient.goldSubtle)
                    .frame(width: 44, height: 44)

                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.alwaysBlack)
            }
            .overlay(Circle().stroke(AppColors.gold.opacity(0.3), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text("ELENA")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundStyle(AppColors.pureWhite)

                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text("Always Online").font(.caption2).foregroundStyle(AppColors.grayLight)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.gold)
                    .padding(10)
                    .background(AppColors.surfaceDark.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
        .background(AppColors.surfaceDark.opacity(0.8))
        .overlay(Rectangle().fill(AppColors.grayDark.opacity(0.2)).frame(height: 1), alignment: .bottom)
    }

    private var messageInputBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColors.grayDark.opacity(0.3))

            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.gold)
                }

                HStack {
                    TextField("Message Elena...", text: $messageText)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.pureWhite)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(messageText.isEmpty ? AppColors.grayDark : AppColors.gold)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.surfaceElevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.grayDark.opacity(0.5), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 34)
            .background(AppColors.surfaceDark.opacity(0.95))
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            Circle().fill(AppColors.grayLight).frame(width: 4, height: 4)
            Circle().fill(AppColors.grayLight).frame(width: 4, height: 4)
            Circle().fill(AppColors.grayLight).frame(width: 4, height: 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.surfaceDark)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Actions

    private func sendMessage() {
        let cleanText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        let userMessage = ChatMessage(text: cleanText, isFromUser: true)
        withAnimation {
            messages.append(userMessage)
            messageText = ""
        }

        // Simulate response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { isTyping = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isTyping = false
                    let response = ChatMessage(
                        text: "Of course! I'll look into that for you right away. Is there anything else you'd like to see?",
                        isFromUser: false
                    )
                    messages.append(response)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }

            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(message.isFromUser ? AppColors.alwaysBlack : AppColors.pureWhite)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isFromUser ?
                    AppColors.gold :
                    AppColors.surfaceDark
                )
                .clipShape(
                    RoundedCorner(
                        radius: 16,
                        corners: message.isFromUser ?
                            [.topLeft, .topRight, .bottomLeft] :
                            [.topLeft, .topRight, .bottomRight]
                    )
                )
                .overlay(
                    RoundedCorner(
                        radius: 16,
                        corners: message.isFromUser ?
                            [.topLeft, .topRight, .bottomLeft] :
                            [.topLeft, .topRight, .bottomRight]
                    )
                    .stroke(message.isFromUser ? .clear : AppColors.gold.opacity(0.2), lineWidth: 1)
                )

            if !message.isFromUser { Spacer() }
        }
    }
}

// MARK: - Models & Mock Data

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

// Extension for partial corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension MockData {
    static var conciergeMessages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm Elena, your personal DIOR advisor. How can I assist you with your style journey today?", isFromUser: false),
        ChatMessage(text: "I'm looking for some gold accessories to match my new watch.", isFromUser: true),
        ChatMessage(text: "Wonderful choice. I would recommend our 'Imperial Gold' collection. Would you like me to curate a selection for you?", isFromUser: false)
    ]
}

#Preview {
    ConciergeView()
}
