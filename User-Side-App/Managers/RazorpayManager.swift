import Foundation
@preconcurrency import Razorpay
import UIKit
import SwiftUI

class RazorpayManager: NSObject {
    @MainActor static let shared = RazorpayManager()
    
    // Replace with your actual Key ID from Razorpay Dashboard
    private let razorpayKey = "rzp_test_Se78LgRbw51U5f"
    
    private var razorpay: RazorpayCheckout?
    @MainActor private var onSuccess: ((String) -> Void)?
    @MainActor private var onFailure: ((String) -> Void)?
    private static var isInitialized = false
    
    override init() {
        super.init()
        // Initialize once during startup on the main thread
        DispatchQueue.main.async {
            self.ensureInitialized()
        }
    }
    
    private func ensureInitialized() {
        if !Self.isInitialized {
            self.razorpay = RazorpayCheckout.initWithKey(self.razorpayKey, andDelegateWithData: self)
            Self.isInitialized = true
            print("💳 RazorpayManager: Strictly Initialized once with key \(self.razorpayKey)")
        }
    }
    
    @MainActor
    func startPayment(orderId: String, amount: Double, email: String, contact: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (String) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        
        let options: [String: Any] = [
            "amount": Int(amount * 100), // Paise
            "currency": "INR",
            "order_id": orderId,
            "name": "LUXE Boutique",
            "description": "Luxury redefined",
            "payment_capture": 1, 
            "prefill": [
                "contact": contact,
                "email": email
            ],
            "theme": [
                "color": "#D4AF37" // LUXE Gold
            ]
        ]
        
        // CRITICAL DEBUG: Print the exact options being sent
        print("DEBUG PAYMENT OPTIONS: \(options)")
        
        ensureInitialized()
        
        if let topController = getTopViewController() {
            razorpay?.open(options, displayController: topController)
        }
    }
    
    @MainActor
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        return topController
    }
}

// MARK: - Razorpay Delegate
extension RazorpayManager: RazorpayPaymentCompletionProtocolWithData {
    
    @objc nonisolated func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("Razorpay Success: \(payment_id)")
        Task { @MainActor in
            onSuccess?(payment_id)
        }
    }
    
    @objc nonisolated func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("Razorpay Error: \(str)")
        Task { @MainActor in
            onFailure?(str)
        }
    }
}

