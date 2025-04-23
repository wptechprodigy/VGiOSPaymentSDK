//
//  APIClientTests.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import XCTest
@testable import VGiOSPaymentSDK

// MARK: - APIClientTests.swift
class APIClientTests: XCTestCase {
    
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        apiClient = APIClient(session: mockURLSession)
    }
    
    func testSuccessfulRequest() {
        // Given
        let expectation = XCTestExpectation(description: "API request should succeed")
        let url = URL(string: "https://api.flutterwave.com/v3/test")!
        let headers = ["Authorization": "Bearer test_key"]
        let responseJSON = ["status": "success", "data": ["id": "12345"]] as [String : Any]
        
        mockURLSession.nextData = try? JSONSerialization.data(withJSONObject: responseJSON)
        mockURLSession.nextResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        apiClient.request(url: url, method: .get, headers: headers, body: nil) { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertEqual(response["status"] as? String, "success")
                if let data = response["data"] as? [String: Any] {
                    XCTAssertEqual(data["id"] as? String, "12345")
                } else {
                    XCTFail("Data should be present in response")
                }
                expectation.fulfill()
                
            case .failure:
                XCTFail("Request should succeed")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "API request should fail with network error")
        let url = URL(string: "https://api.flutterwave.com/v3/test")!
        let headers = ["Authorization": "Bearer test_key"]
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        
        mockURLSession.nextError = networkError
        
        // When
        apiClient.request(url: url, method: .get, headers: headers, body: nil) { result in
            // Then
            switch result {
            case .failure(let error):
                if case .networkError(let underlyingError) = error {
                    XCTAssertEqual((underlyingError as NSError).domain, NSURLErrorDomain)
                    XCTAssertEqual((underlyingError as NSError).code, NSURLErrorNotConnectedToInternet)
                } else {
                    XCTFail("Error should be networkError")
                }
                expectation.fulfill()
                
            case .success:
                XCTFail("Request should fail")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAPIError() {
        // Given
        let expectation = XCTestExpectation(description: "API request should fail with API error")
        let url = URL(string: "https://api.flutterwave.com/v3/test")!
        let headers = ["Authorization": "Bearer test_key"]
        let errorJSON = ["status": "error", "message": "Invalid API key"]
        
        mockURLSession.nextData = try? JSONSerialization.data(withJSONObject: errorJSON)
        mockURLSession.nextResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        
        // When
        apiClient.request(url: url, method: .get, headers: headers, body: nil) { result in
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
                XCTFail("Request should fail")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
