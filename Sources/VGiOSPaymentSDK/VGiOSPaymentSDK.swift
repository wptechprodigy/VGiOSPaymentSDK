//
//  VGiOSPaymentSDK.swift
//
//
//  Created by waheedCodes on 22/04/2025.
//

import Foundation
import UIKit
import WebKit

public class VGiOSPaymentSDK {
    
    // MARK: - Properties
    public static let shared = VGiOSPaymentSDK()
    private var configuration: Configuration?
    
    // Property to support dependency injection
    private var paymentManager: PaymentManager
    
    // MARK: - Initialization
    // Update initializer to support dependency injection
    public init(paymentManager: PaymentManager = .shared) {
        self.paymentManager = paymentManager
    }
    
    // Add getter for testing purposes
    internal var currentConfiguration: Configuration? {
        return configuration
    }
    
    // MARK: - Configuration
    public func initialize(publicKey: String, encryptionKey: String, environment: Environment = .production) {
        self.configuration = Configuration(
            publicKey: publicKey,
            encryptionKey: encryptionKey,
            environment: environment
        )
        Logger.log("VGiOSPaymentSDK initialized successfully")
    }
    
    // MARK: - Payment Methods
    public func startPayment(
        amount: Double,
        currency: Currency,
        customerEmail: String,
        customerName: String,
        customerPhone: String? = nil,
        reference: String? = nil,
        narration: String? = nil,
        metadata: [String: Any]? = nil,
        completion: @escaping (Result<PaymentResponse, VGPaymentError>) -> Void
    ) {
        guard let configuration = configuration else {
            completion(.failure(.notInitialized))
            return
        }
        
        let paymentRequest = PaymentRequest(
            amount: amount,
            currency: currency,
            customerEmail: customerEmail,
            customerName: customerName,
            customerPhone: customerPhone,
            reference: reference ?? generateReference(),
            narration: narration,
            metadata: metadata
        )
        
        paymentManager.processPayment(
            request: paymentRequest,
            configuration: configuration,
            completion: completion
        )
    }
    
    public func initializePaymentViewController(
        amount: Double,
        currency: Currency,
        customerEmail: String,
        customerName: String,
        customerPhone: String? = nil,
        reference: String? = nil,
        narration: String? = nil,
        metadata: [String: Any]? = nil,
        delegate: PaymentViewControllerDelegate,
        apiClient: APIClient = .shared
    ) -> UIViewController? {
        guard let configuration = configuration else {
            delegate.didFailPayment(with: .notInitialized)
            return nil
        }
        
        let paymentRequest = PaymentRequest(
            amount: amount,
            currency: currency,
            customerEmail: customerEmail,
            customerName: customerName,
            customerPhone: customerPhone,
            reference: reference ?? generateReference(),
            narration: narration,
            metadata: metadata
        )
        
        let paymentVC = PaymentViewController(
            paymentRequest: paymentRequest,
            configuration: configuration,
            delegate: delegate,
            apiClient: apiClient
        )
        
        return paymentVC
    }
    
    // MARK: - Helper Methods
    private func generateReference() -> String {
        return "VG-\(UUID().uuidString.prefix(8))-\(Int(Date().timeIntervalSince1970))"
    }
}
