//
//  PaymentRequest.swift
//  
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

struct PaymentRequest {
    let amount: Double
    let currency: Currency
    let customerEmail: String
    let customerName: String
    let customerPhone: String?
    let reference: String
    let narration: String?
    let metadata: [String: Any]?
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "amount": amount,
            "currency": currency.rawValue,
            "customer": [
                "email": customerEmail,
                "name": customerName
            ],
            "tx_ref": reference
        ]
        
        if let phone = customerPhone {
            dict["customer"] = (dict["customer"] as? [String: Any])?.merging(["phone_number": phone], uniquingKeysWith: { $1 })
        }
        
        if let narration = narration {
            dict["narration"] = narration
        }
        
        if let metadata = metadata {
            dict["meta"] = metadata
        }
        
        return dict
    }
}
