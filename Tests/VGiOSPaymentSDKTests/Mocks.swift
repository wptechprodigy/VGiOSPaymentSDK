//
//  Mocks.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

//import XCTest
@testable import VGiOSPaymentSDK
import WebKit

class MockURLSession: URLSession {
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask()
        task.completionHandler = {
            completionHandler(self.nextData, self.nextResponse, self.nextError)
        }
        return task
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: (() -> Void)?
    
    override func resume() {
        completionHandler?()
    }
}

class MockAPIClient: APIClient {
    var nextResult: Result<[String: Any], VGPaymentError>?
    
    override func request(url: URL, method: HTTPMethod, headers: [String: String], body: Data?, completion: @escaping (Result<[String: Any], VGPaymentError>) -> Void) {
        if let result = nextResult {
            completion(result)
        }
    }
}

class MockPaymentDelegate: PaymentViewControllerDelegate {
    var didCompleteCalled = false
    var didFailCalled = false
    var didCancelCalled = false
    var lastResponse: PaymentResponse?
    var lastError: VGPaymentError?
    
    // Add this callback property
    var onCancelCallback: (() -> Void)?
    
    func didCompletePayment(with response: PaymentResponse) {
        didCompleteCalled = true
        lastResponse = response
    }
    
    func didFailPayment(with error: VGPaymentError) {
        didFailCalled = true
        lastError = error
    }
    
    func didCancelPayment() {
        didCancelCalled = true
        onCancelCallback?()
    }
}

// Better MockWKNavigationAction implementation
class MockWKNavigationAction: WKNavigationAction {
    private let mockRequest: URLRequest
    
    init(_ url: URL) {
        self.mockRequest = URLRequest(url: url)
        super.init()
    }
    
    override var request: URLRequest {
        return mockRequest
    }
    
    // Implementing required properties
    override var navigationType: WKNavigationType {
        return .linkActivated
    }
    
    override var sourceFrame: WKFrameInfo {
        fatalError("Not implemented - not needed for tests")
    }
    
    override var targetFrame: WKFrameInfo? {
        fatalError("Not implemented - not needed for tests")
    }
}

// Add a protocol for better testability in future
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

// Protocol extension to make URLSession more testable
extension URLSession: URLSessionProtocol {}
