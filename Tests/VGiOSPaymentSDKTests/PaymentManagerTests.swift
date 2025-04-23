//
//  PaymentManagerTests.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import XCTest
@testable import VGiOSPaymentSDK

class PaymentManagerTests: XCTestCase {
    
    var paymentManager: PaymentManager!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        paymentManager = PaymentManager(apiClient: mockAPIClient)
    }
    
    func testSuccessfulPaymentProcessing() {
        // Given
        let expectation = XCTestExpectation(description: "Payment should process successfully")
        let request = PaymentRequest(
            amount: 1000.0,
            currency: .ngn,
            customerEmail: "test@example.com",
            customerName: "Test User",
            customerPhone: nil,
            reference: "test-ref-123",
            narration: nil,
            metadata: nil
        )
        
        let configuration = Configuration(
            publicKey: "test_public_key",
            encryptionKey: "test_encryption_key",
            environment: .sandbox
        )
        
        let successResponse: [String: Any] = [
            "status": "success",
            "message": "Payment link created",
            "data": [
                "id": "12345",
                "tx_ref": "test-ref-123",
                "amount": 1000.0,
                "currency": "NGN",
                "status": "successful",
                "payment_type": "card",
                "customer": [
                    "email": "test@example.com",
                    "name": "Test User"
                ],
                "created_at": "2023-04-22T10:30:00.000Z"
            ]
        ]
        
        mockAPIClient.nextResult = .success(successResponse)
        
        // When
        paymentManager.processPayment(request: request, configuration: configuration) { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertEqual(response.transactionId, "12345")
                XCTAssertEqual(response.transactionReference, "test-ref-123")
                XCTAssertEqual(response.amount, 1000.0)
                XCTAssertEqual(response.currency, "NGN")
                XCTAssertEqual(response.status, .successful)
                expectation.fulfill()
                
            case .failure:
                XCTFail("Payment processing should succeed")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailedPaymentProcessing() {
        // Given
        let expectation = XCTestExpectation(description: "Payment should fail with API error")
        let request = PaymentRequest(
            amount: 1000.0,
            currency: .ngn,
            customerEmail: "test@example.com",
            customerName: "Test User",
            customerPhone: nil,
            reference: "test-ref-123",
            narration: nil,
            metadata: nil
        )
        
        let configuration = Configuration(
            publicKey: "test_public_key",
            encryptionKey: "test_encryption_key",
            environment: .sandbox
        )
        
        mockAPIClient.nextResult = .failure(.apiError("Invalid API key", 401))
        
        // When
        paymentManager.processPayment(request: request, configuration: configuration) { result in
            // Then
            switch result {
            case .failure(let error):
                if case .apiError(let message, let code) = error {
                    XCTAssertEqual(message, "Invalid API key")
                    XCTAssertEqual(code, 401)
                } else {
                    XCTFail("Error should be apiError")
                }
                expectation.fulfill()
                
            case .success:
                XCTFail("Payment processing should fail")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
