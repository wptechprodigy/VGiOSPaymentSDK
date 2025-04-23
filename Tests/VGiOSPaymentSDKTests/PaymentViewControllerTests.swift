//
//  PaymentViewControllerTests.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import XCTest
@testable import VGiOSPaymentSDK
import WebKit

// MARK: - PaymentViewControllerTests.swift
class PaymentViewControllerTests: XCTestCase {
    
    var paymentVC: PaymentViewController!
    var mockDelegate: MockPaymentDelegate!
    var mockAPIClient: MockAPIClient!
    var request: PaymentRequest!
    var configuration: Configuration!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockPaymentDelegate()
        mockAPIClient = MockAPIClient()
        
        request = PaymentRequest(
            amount: 1000.0,
            currency: .ngn,
            customerEmail: "test@example.com",
            customerName: "Test User",
            customerPhone: nil,
            reference: "test-ref-123",
            narration: nil,
            metadata: nil
        )
        
        configuration = Configuration(
            publicKey: "test_public_key",
            encryptionKey: "test_encryption_key",
            environment: .sandbox
        )
        
        paymentVC = PaymentViewController(
            paymentRequest: request,
            configuration: configuration,
            delegate: mockDelegate,
            apiClient: mockAPIClient
        )
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func testCloseButtonTapped() {
        /// Given
        let navigationController = UINavigationController(rootViewController: paymentVC)
        let expectation = XCTestExpectation(description: "Delegate method should be called")
        
        // Force view to load
        _ = paymentVC.view
        
        // Setup mock delegate to fulfill expectation
        mockDelegate.onCancelCallback = {
            expectation.fulfill()
        }
        
        // When
        paymentVC.closeTapped()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockDelegate.didCancelCalled)
    }
    
    func testWebViewCallbackURL() {
        // Given
        _ = paymentVC.view  // Force view to load
        
        let callbackURL = URL(string: "https://your-app.com/flutterwave-callback?status=successful&tx_ref=test-ref-123")!
        let navigationAction = MockWKNavigationAction(callbackURL)
        
        // When
        var policy: WKNavigationActionPolicy?
        paymentVC.webView(paymentVC.webView, decidePolicyFor: navigationAction) { actionPolicy in
            policy = actionPolicy
        }
        
        // Then
        XCTAssertEqual(policy, .cancel)
        
        // Test verification called
        let successResponse: [String: Any] = [
            "status": "success",
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
        
        // Wait for API call
        let expectation = XCTestExpectation(description: "Verification should complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testVerifyPayment() {
        // Given
        _ = paymentVC.view  // Force view to load
        
        let successResponse: [String: Any] = [
            "status": "success",
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
        paymentVC.verifyPayment(reference: "test-ref-123")
        
        // Wait for API call and dismiss animation
        let expectation = XCTestExpectation(description: "Verification should complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then - test that the delegate was called with the response
        XCTAssertTrue(mockDelegate.didCompleteCalled)
        XCTAssertEqual(mockDelegate.lastResponse?.transactionReference, "test-ref-123")
    }
}
