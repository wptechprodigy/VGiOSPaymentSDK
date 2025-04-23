//
//  PaymentResponse.swift
//  
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

public struct PaymentResponse {
    public let transactionId: String
    public let transactionReference: String
    public let amount: Double
    public let currency: String
    public let status: PaymentStatus
    public let customerEmail: String
    public let customerName: String
    public let paymentMethod: String
    public let createdAt: Date
    public let rawResponse: [String: Any]
    
    init?(from response: [String: Any]) {
        guard let data = response["data"] as? [String: Any],
              let transactionId = data["id"] as? String,
              let txRef = data["tx_ref"] as? String,
              let amount = data["amount"] as? Double,
              let currency = data["currency"] as? String,
              let statusString = data["status"] as? String,
              let customer = data["customer"] as? [String: Any],
              let customerEmail = customer["email"] as? String,
              let customerName = customer["name"] as? String,
              let paymentMethod = data["payment_type"] as? String,
              let createdAtString = data["created_at"] as? String else {
            return nil
        }
        
        self.transactionId = transactionId
        self.transactionReference = txRef
        self.amount = amount
        self.currency = currency
        self.status = PaymentStatus(rawValue: statusString.lowercased()) ?? .unknown
        self.customerEmail = customerEmail
        self.customerName = customerName
        self.paymentMethod = paymentMethod
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        self.rawResponse = response
    }
}
