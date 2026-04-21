import Foundation

// Simulate the error parsing logic from CheckoutView.swift
func parseEdgeFunctionError(status: Int, data: Data) -> String {
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let message = json["error"] as? String {
        return "Edge Function Error (\(status)): \(message)"
    } else if let bodyString = String(data: data, encoding: .utf8) {
        return "Edge Function Error (\(status)): \(bodyString)"
    }
    return "Unknown Error (\(status))"
}

// Test Case 1: Missing Keys Error
let missingKeysJson = "{\"error\": \"Razorpay keys are not configured in Supabase secrets. Please run: supabase secrets set RAZORPAY_KEY_ID=... RAZORPAY_KEY_SECRET=...\"}"
let data1 = missingKeysJson.data(using: .utf8)!
print("Test 1 Result: \(parseEdgeFunctionError(status: 400, data: data1))")

// Test Case 2: Generic HTML Error
let genericError = "Bad Request"
let data2 = genericError.data(using: .utf8)!
print("Test 2 Result: \(parseEdgeFunctionError(status: 400, data: data2))")

// Test Case 3: Empty body
print("Test 3 Result: \(parseEdgeFunctionError(status: 500, data: Data()))")
