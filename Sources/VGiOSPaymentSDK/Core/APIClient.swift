//
//  APIClient.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

public class APIClient {
    public static let shared = APIClient()
    
    // Support for dependency injection
    private var session: URLSession
    
    // Custom initializer for dependency injection
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String],
        body: Data?,
        completion: @escaping (Result<[String: Any], VGPaymentError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unexpectedError("Invalid response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorResponse["message"] as? String {
                    completion(.failure(.apiError(message, httpResponse.statusCode)))
                } else {
                    completion(.failure(.apiError("Unknown API error", httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(.unexpectedError("Invalid JSON response")))
                return
            }
            
            completion(.success(jsonResponse))
        }
        
        task.resume()
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}
