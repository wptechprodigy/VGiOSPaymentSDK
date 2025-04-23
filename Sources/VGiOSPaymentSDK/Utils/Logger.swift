//
//  Logger.swift
//  
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

class Logger {
    static func log(_ message: String) {
        #if DEBUG
        print("[VGiOSPaymentSDK] \(message)")
        #endif
    }
}
