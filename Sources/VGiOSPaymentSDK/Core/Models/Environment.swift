//
//  File.swift
//  
//
//  Created by waheedCodes on 22/04/2025.
//

import Foundation

public enum Environment {
    case sandbox
    case production
    
    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://api.flutterwave.com/v3"
        case .production:
            return "https://api.flutterwave.com/v3"
        }
    }
}
