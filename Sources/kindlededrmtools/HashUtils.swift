//
//  HashUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CryptoKit

enum HashUtils {
    /**
     * Computes the SHA-256 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-256 hash of the data.
     */
    static func sha256(data: Data?...) -> Data {
        var hasher = SHA256()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
    
    /**
     * Computes the MD5 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The MD5 hash of the data.
     */
    static func md5(data: Data?...) -> Data {
        var hasher = Insecure.MD5()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
    
    /**
     * Computes the SHA-1 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-1 hash of the data.
     */
    static func sha1(data: Data?...) -> Data {
        var hasher = Insecure.SHA1()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
}
