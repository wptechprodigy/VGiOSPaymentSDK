//
//  PaymentManager.swift
//  
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

public class PaymentManager {
    public static let shared = PaymentManager()
    
    // Add this property to support dependency injection
    private var apiClient: APIClient
    
    // Custom initializer for dependency injection
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func processPayment(
        request: PaymentRequest,
        configuration: Configuration,
        completion: @escaping (Result<PaymentResponse, VGPaymentError>) -> Void
    ) {
        // Prepare API request
        guard let url = URL(string: "\(configuration.baseURL)/payments") else {
            completion(.failure(.unexpectedError("Invalid URL")))
            return
        }
        
        let headers = [
            "Authorization": "Bearer \(configuration.publicKey)",
            "Content-Type": "application/json"
        ]
        
        let paymentData = request.toDict()
        
        guard let body = try? JSONSerialization.data(withJSONObject: paymentData) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        // Make API request
        apiClient.request(
            url: url,
            method: .post,
            headers: headers,
            body: body
        ) { result in
            switch result {
            case .success(let response):
                guard let status = response["status"] as? String, status == "success",
                      let paymentResponse = PaymentResponse(from: response) else {
                    completion(.failure(.unexpectedError("Invalid payment response")))
                    return
                }
                completion(.success(paymentResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
