//
//  CryptoUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CryptoKit
import CommonCrypto

enum CryptoUtils {
    /**
     * Computes the HMAC-SHA256 hash of the given message using the provided key.
     * - Parameters:
     *   - key: The key to use for the HMAC.
     *   - message: The message to hash.
     * - Returns: The HMAC-SHA256 hash of the message as `Data`.
     */
    static func hmacsha256(key: Data, message: Data) -> Data {
        let symmetricKey: SymmetricKey = .init(data: key)
        let authenticationCode: HashedAuthenticationCode<SHA256> = HMAC<SHA256>.authenticationCode(for: message, using: symmetricKey)
        return .init(authenticationCode)
    }
    
    static func hmacsha256(_ key: Data, _ message: Data) -> Data {
        return hmacsha256(key: key, message: message)
    }
    
    /**
     * Decrypts the given ciphertext using AES/CBC with the provided key and IV.
     * - Parameters:
     *   - key: The key to use for AES/CBC decryption.
     *   - iv: The initialization vector.
     *   - cipherText: The encrypted data.
     * - Returns: The decrypted data as `Data`.
     */
    static func aescbcdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        return try .init(QCCAESPadCBCDecrypt(key: .init(key), iv: .init(iv), cipherText: .init(cipherText)))
    }
    
    static func aescbcdecrypt(_ key: Data, _ iv: Data, _ cipherText: Data) throws -> Data {
        return try aescbcdecrypt(key: key, iv: iv, cipherText: cipherText)
    }
    
    /**
     * Decrypts the given ciphertext using AES/CTR with the provided key and IV.
     * - Parameters:
     *   - key: The key to use for AES/CTR decryption.
     *   - iv: The initialization vector.
     *   - cipherText: The encrypted data.
     * - Returns: The decrypted data as `Data`.
     */
    static func aesctrdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        let symmetricKey: SymmetricKey = .init(data: key)
        let nonce: AES.GCM.Nonce = try .init(data: iv)
        let sealedBox: AES.GCM.SealedBox = try .init(nonce: nonce, ciphertext: cipherText, tag: Data())
        let decryptedData: Data = try AES.GCM.open(sealedBox, using: symmetricKey)
        return decryptedData
    }
    
    /// Encrypts data using AES with PKCS#7 padding in CBC mode.
    ///
    /// - note: PKCS#7 padding is also known as PKCS#5 padding.
    ///
    /// - Parameters:
    ///   - key: The key to encrypt with; must be a supported size (128, 192, 256).
    ///   - iv: The initialisation vector; must be of size 16.
    ///   - plainText: The data to encrypt; the PKCS#7 padding means there are no
    ///     constraints on its length.
    /// - Returns: The encrypted data; it’s length with always be an even multiple of 16.
    private static func QCCAESPadCBCEncrypt(key: [UInt8], iv: [UInt8], plainText: [UInt8]) throws -> [UInt8] {
        // The key size must be 128, 192, or 256.
        //
        // The IV size must match the block size.
        guard
            [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(key.count),
            iv.count == kCCBlockSizeAES128
        else {
            throw QCCError(code: kCCParamError)
        }
        
        // Padding can expand the data, so we have to allocate space for that.  The
        // rule for block ciphers, like AES, is that the padding only adds space on
        // encryption (on decryption it can reduce space, obviously, but we don't
        // need to account for that) and it will only add at most one block size
        // worth of space.
        var ciphertext: [UInt8] = .init(repeating: 0, count: plainText.count + kCCBlockSizeAES128)
        var ciphertextCount: Int = 0
        let err: CCCryptorStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key, key.count,
            iv,
            plainText, plainText.count,
            &ciphertext, ciphertext.count,
            &ciphertextCount
        )
        
        guard err == kCCSuccess else {
            throw QCCError(code: err)
        }
        
        // The ciphertext can expand by up to one block but it doesn’t always use the full block,
        // so trim off any unused bytes.
        assert(ciphertextCount <= ciphertext.count)
        ciphertext.removeLast(ciphertext.count - ciphertextCount)
        assert(ciphertext.count.isMultiple(of: kCCBlockSizeAES128))
        
        return ciphertext
    }
    
    /// Decrypts data that was encrypted using AES with PKCS#7 padding in CBC mode.
    ///
    /// - note: PKCS#7 padding is also known as PKCS#5 padding.
    ///
    /// - Parameters:
    ///   - key: The key to encrypt with; must be a supported size (128, 192, 256).
    ///   - iv: The initialisation vector; must be of size 16.
    ///   - cipherText: The encrypted data; it’s length must be an even multiple of
    ///     16.
    /// - Returns: The decrypted data.
    private static func QCCAESPadCBCDecrypt(key: [UInt8], iv: [UInt8], cipherText: [UInt8]) throws -> [UInt8] {
        // The key size must be 128, 192, or 256.
        //
        // The IV size must match the block size.
        //
        // The ciphertext must be a multiple of the block size.
        guard
            [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(key.count),
            iv.count == kCCBlockSizeAES128,
            cipherText.count.isMultiple(of: kCCBlockSizeAES128)
        else {
            throw QCCError(code: kCCParamError)
        }
        
        // Padding can expand the data on encryption, but on decryption the data can
        // only shrink so we use the ciphertext size as our plaintext size.
        var plaintext: [UInt8] = .init(repeating: 0, count: cipherText.count)
        var plaintextCount: Int = 0
        let err: CCCryptorStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key, key.count,
            iv,
            cipherText, cipherText.count,
            &plaintext, plaintext.count,
            &plaintextCount
        )
        
        guard err == kCCSuccess else {
            throw QCCError(code: err)
        }
        
        // Trim any unused bytes off the plaintext.
        assert(plaintextCount <= plaintext.count)
        plaintext.removeLast(plaintext.count - plaintextCount)
        
        return plaintext
    }
}
