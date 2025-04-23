//
//  VGPaymentError.swift
//  
//
//  Created by waheedCodes on 22/04/2025.
//

import Foundation

public enum VGPaymentError: Error, Equatable {
    case notInitialized
    case invalidRequest
    case networkError(Error)
    case apiError(String, Int)
    case paymentCancelled
    case unexpectedError(String)
    
    var localizedDescription: String {
        switch self {
        case .notInitialized:
            return "VGiOSPaymentSDK not initialized. Call initialize() first."
        case .invalidRequest:
            return "Invalid payment request parameters."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message, let code):
            return "API error (\(code)): \(message)"
        case .paymentCancelled:
            return "Payment was cancelled by the user."
        case .unexpectedError(let message):
            return "Unexpected error: \(message)"
        }
    }
    
    // Custom implementation of Equatable for comparing errors with associated values
    public static func == (lhs: VGPaymentError, rhs: VGPaymentError) -> Bool {
        switch (lhs, rhs) {
        case (.notInitialized, .notInitialized),
             (.invalidRequest, .invalidRequest),
             (.paymentCancelled, .paymentCancelled):
            return true
        case (.networkError, .networkError),
             (.unexpectedError, .unexpectedError):
            // Consider them equal in tests (ignoring the associated values)
            return true
        case (.apiError(let lhsMessage, let lhsCode), .apiError(let rhsMessage, let rhsCode)):
            return lhsMessage == rhsMessage && lhsCode == rhsCode
        default:
            return false
        }
    }
}
