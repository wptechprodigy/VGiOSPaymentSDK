//
//  Security.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation
import CommonCrypto

class Security {
    static func encrypt(data: String, using key: String) -> String? {
        return encryptWithKey(payload: ["data": data], encryptionKey: key)
    }
    
    static func encryptWithKey(payload: [String: Any], encryptionKey: String) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let dataToEncrypt = String(data: jsonData, encoding: .utf8)?.data(using: .utf8),
              let keyData = encryptionKey.data(using: .utf8) else {
            return nil
        }
        
        let keyLength = size_t(kCCKeySize3DES)
        let dataLength = size_t(dataToEncrypt.count)
        let bufferSize = dataLength + kCCBlockSize3DES
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            dataToEncrypt.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithm3DES),
                            CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyLength,
                            nil,
                            dataBytes.baseAddress, dataLength,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesEncrypted)
                }
            }
        }
        
        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            let encryptedData = buffer[..<numBytesEncrypted]
            return encryptedData.base64EncodedString()
        }
        return nil
    }
}
