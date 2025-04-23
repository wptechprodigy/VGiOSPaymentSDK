//
//  Configuration.swift
//  
//
//  Created by waheedCodes on 22/04/2025.
//

import Foundation

struct Configuration {
    let publicKey: String
    let encryptionKey: String
    let environment: Environment
    
    var baseURL: String {
        return environment.baseURL
    }
}
