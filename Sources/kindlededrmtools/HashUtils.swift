//
//  HashUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CryptoKit

final class HashUtils {
    private init() {}
    
    /**
     * Computes the SHA-256 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-256 hash of the data.
     */
    public static func sha256(data: Data...) -> Data {
        var hasher = SHA256()
        
        for bytes in data {
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
    
    /**
     * Computes the MD5 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The MD5 hash of the data.
     */
    public static func md5(data: Data...) -> Data {
        var hasher = Insecure.MD5()
        
        for bytes in data {
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
    
    /**
     * Computes the SHA-1 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-1 hash of the data.
     */
    public static func sha1(data: Data...) -> Data {
        var hasher = Insecure.SHA1()
        
        for bytes in data {
            hasher.update(data: bytes)
        }
        
        return Data(hasher.finalize())
    }
}
