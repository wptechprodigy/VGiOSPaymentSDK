import XCTest
@testable import VGiOSPaymentSDK
//import WebKit

class VGiOSPaymentSDKTests: XCTestCase {
    
    var sdk: VGiOSPaymentSDK!
    
    override func setUp() {
        super.setUp()
        // Create a fresh instance for each test
        sdk = VGiOSPaymentSDK()
    }
    
    func testInitialization() {
        // Given
        let publicKey = "test_public_key"
        let encryptionKey = "test_encryption_key"
        
        // When
        sdk.initialize(publicKey: publicKey, encryptionKey: encryptionKey, environment: .sandbox)
        
        // Then
        XCTAssertNotNil(sdk.currentConfiguration)
        XCTAssertEqual(sdk.currentConfiguration?.publicKey, publicKey)
        XCTAssertEqual(sdk.currentConfiguration?.encryptionKey, encryptionKey)
        XCTAssertEqual(sdk.currentConfiguration?.environment, .sandbox)
    }
    
    func testStartPaymentWithoutInitialization() {
        // Given
        let expectation = XCTestExpectation(description: "Payment should fail with not initialized error")
        
        // When
        sdk.startPayment(
            amount: 1000.0,
            currency: .ngn,
            customerEmail: "test@example.com",
            customerName: "Test User",
            completion: { result in
                // Then
                switch result {
                case .failure(let error):
                    XCTAssertEqual(error, .notInitialized)
                    expectation.fulfill()
                case .success:
                    XCTFail("Payment should not succeed without initialization")
                }
            }
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPaymentRequestCreation() {
        // Given
        let amount = 1000.0
        let currency = Currency.ngn
        let email = "test@example.com"
        let name = "Test User"
        let phone = "1234567890"
        let reference = "test-ref-123"
        let narration = "Test payment"
        let metadata = ["key": "value"]
        
        // When
        let request = PaymentRequest(
            amount: amount,
            currency: currency,
            customerEmail: email,
            customerName: name,
            customerPhone: phone,
            reference: reference,
            narration: narration,
            metadata: metadata
        )
        
        // Then
        let dict = request.toDict()
        XCTAssertEqual(dict["amount"] as? Double, amount)
        XCTAssertEqual(dict["currency"] as? String, currency.rawValue)
        XCTAssertEqual(dict["tx_ref"] as? String, reference)
        XCTAssertEqual(dict["narration"] as? String, narration)
        
        if let customer = dict["customer"] as? [String: Any] {
            XCTAssertEqual(customer["email"] as? String, email)
            XCTAssertEqual(customer["name"] as? String, name)
            XCTAssertEqual(customer["phone_number"] as? String, phone)
        } else {
            XCTFail("Customer dictionary should be present")
        }
        
        XCTAssertEqual(dict["meta"] as? [String: String], metadata)
    }
    
    func testPaymentResponseParsing() {
        // Given
        let responseJSON: [String: Any] = [
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
        
        // When
        let response = PaymentResponse(from: responseJSON)
        
        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.transactionId, "12345")
        XCTAssertEqual(response?.transactionReference, "test-ref-123")
        XCTAssertEqual(response?.amount, 1000.0)
        XCTAssertEqual(response?.currency, "NGN")
        XCTAssertEqual(response?.status, .successful)
        XCTAssertEqual(response?.customerEmail, "test@example.com")
        XCTAssertEqual(response?.customerName, "Test User")
        XCTAssertEqual(response?.paymentMethod, "card")
    }
    
    func testInvalidPaymentResponseParsing() {
        // Given
        let invalidResponseJSON: [String: Any] = [
            "status": "success",
            "message": "Payment link created",
            "data": [
                "amount": 1000.0  // Missing required fields
            ]
        ]
        
        // When
        let response = PaymentResponse(from: invalidResponseJSON)
        
        // Then
        XCTAssertNil(response)
    }
}
