//
//  HashUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CryptoKit
import CryptoSwift

final class HashUtils {
    private init() {}
    
    /**
     * Computes the SHA-256 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-256 hash of the data.
     */
    static func sha256(data: [Data?]) -> Data {
        if #available(macOS 10.15, *) {
            return cryptoswiftSha256(data: data)
        } else {
            return cryptoswiftSha256(data: data)
        }
    }
    
    @available(macOS 10.15, *)
    private static func cryptokitSha256(data: [Data?]) -> Data {
        var hasher: SHA256 = .init()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return .init(hasher.finalize())
    }
    
    private static func cryptoswiftSha256(data: [Data?]) -> Data {
        let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
        return .init(bytes.sha2(.sha256))
    }
    
    static func sha256(data: Data?...) -> Data {
        return sha256(data: data)
    }
    
    /**
     * Computes the MD5 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The MD5 hash of the data.
     */
    static func md5(data: [Data?]) -> Data {
        if #available(macOS 10.15, *) {
            return cryptoswiftMd5(data: data)
        } else {
            return cryptoswiftMd5(data: data)
        }
    }
    
    @available(macOS 10.15, *)
    private static func cryptokitMd5(data: [Data?]) -> Data {
        var hasher: Insecure.MD5 = .init()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return .init(hasher.finalize())
    }
    
    private static func cryptoswiftMd5(data: [Data?]) -> Data {
        let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
        return .init(bytes.md5())
    }
    
    static func md5(data: Data?...) -> Data {
        return md5(data: data)
    }
    
    /**
     * Computes the SHA-1 hash of the given data.
     * - Parameter data: The data to hash.
     * - Returns: The SHA-1 hash of the data.
     */
    static func sha1(data: [Data?]) -> Data {
        if #available(macOS 10.15, *) {
            return cryptoswiftSha1(data: data)
        } else {
            return cryptoswiftSha1(data: data)
        }
    }
    
    @available(macOS 10.15, *)
    private static func cryptokitSha1(data: [Data?]) -> Data {
        var hasher: Insecure.SHA1 = .init()
        
        for bytes in data {
            guard let bytes else {
                continue
            }
            
            hasher.update(data: bytes)
        }
        
        return .init(hasher.finalize())
    }
    
    private static func cryptoswiftSha1(data: [Data?]) -> Data {
        let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
        return .init(bytes.sha1())
    }
    
    static func sha1(data: Data?...) -> Data {
        return sha1(data: data)
    }
}

// MARK: - Convenience Functions
extension HashUtils {
    static func sha256(_ data: [Data?]) -> Data {
        return sha256(data: data)
    }
    
    static func sha256(_ data: Data?...) -> Data {
        return sha256(data: data)
    }
    
    static func md5(_ data: [Data?]) -> Data {
        return md5(data: data)
    }
    
    static func md5(_ data: Data?...) -> Data {
        return md5(data: data)
    }
    
    static func sha1(_ data: [Data?]) -> Data {
        return sha1(data: data)
    }
    
    static func sha1(_ data: Data?...) -> Data {
        return sha1(data: data)
    }
}
