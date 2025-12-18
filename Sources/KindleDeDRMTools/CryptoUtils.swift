//
//  CryptoUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif
import CommonCrypto
import CryptoSwift

final class CryptoUtils {
    private init() {}

    /**
     * Computes the HMAC-SHA256 hash of the given message using the provided key.
     * - Parameters:
     *   - key: The key to use for the HMAC.
     *   - message: The message to hash.
     * - Returns: The HMAC-SHA256 hash of the message as `Data`.
     */
    static func hmacsha256(key: Data, message: Data) throws -> Data {
#if canImport(CryptoKit) && compiler(>=5.1)
        if !preferCryptoSwift, usePlatformChecks, #available(macOS 10.15, iOS 13.0, *) {
            return cryptokitHmacsha256(key: key, message: message)
        } else {
            return try cryptoswiftHmacsha256(key: key, message: message)
        }
#else
        return try cryptoswiftHmacsha256(key: key, message: message)
#endif
    }

#if canImport(CryptoKit) && compiler(>=5.1)
    @available(macOS 10.15, iOS 13.0, *)
    private static func cryptokitHmacsha256(key: Data, message: Data) -> Data {
        let symmetricKey: SymmetricKey = .init(data: key)
        let authenticationCode: HashedAuthenticationCode<SHA256> = HMAC.authenticationCode(for: message, using: symmetricKey)
        return .init(authenticationCode)
    }
#endif

    private static func cryptoswiftHmacsha256(key: Data, message: Data) throws -> Data {
        let hmac: CryptoSwift.HMAC = .init(key: key.byteArray, variant: .sha2(.sha256))
        let authenticationCode: [UInt8] = try hmac.authenticate(message.byteArray)
        return .init(authenticationCode)
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
        if preferCryptoSwift {
            return try cryptoswiftAescbcdecrypt(key: key, iv: iv, cipherText: cipherText)
        } else {
            return try commoncryptoAescbcdecrypt(key: key, iv: iv, cipherText: cipherText)
        }
    }

    private static func commoncryptoAescbcdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        return try .init(QCCAESPadCBCDecrypt(key: .init(key), iv: .init(iv), cipherText: .init(cipherText)))
    }

    private static func cryptoswiftAescbcdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        let aes: CryptoSwift.AES = try .init(
            key: key.byteArray,
            blockMode: CBC(iv: iv.byteArray),
            padding: .pkcs5
        )

        let decrypted: [UInt8] = try aes.decrypt(cipherText.byteArray)
        return .init(decrypted)
    }

    static func aesctrdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        return try cryptoswiftAesctrdecrypt(key: key, iv: iv, cipherText: cipherText)
    }

    private static func cryptoswiftAesctrdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
        let aes: CryptoSwift.AES = try .init(
            key: key.byteArray,
            blockMode: CTR(iv: iv.byteArray),
            padding: .noPadding
        )

        let decrypted: [UInt8] = try aes.decrypt(cipherText.byteArray)
        return .init(decrypted)
    }

    static func pbkdf2hmacsha1(password: Data, salt: Data, iterationCount: Int, keyLength: Int) throws -> Data {
        if preferCryptoSwift {
            return try cryptoswiftPbkdf2hmacsha1(password: password, salt: salt, iterationCount: iterationCount, keyLength: keyLength)
        } else {
            return try commoncryptoPbkdf2hmacsha1(password: password, salt: salt, iterationCount: iterationCount, keyLength: keyLength)
        }
    }

    private static func commoncryptoPbkdf2hmacsha1(password: Data, salt: Data, iterationCount: Int, keyLength: Int) throws -> Data {
        var derivedKey: Data = .init(count: keyLength)

        let status: Int32 = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            password.withUnsafeBytes { passwordBytes in
                salt.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.bindMemory(to: Int8.self).baseAddress,
                        password.count,
                        saltBytes.bindMemory(to: UInt8.self).baseAddress,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                        UInt32(iterationCount),
                        derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                        keyLength
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw QCCError(code: status)
        }

        return derivedKey
    }

    private static func cryptoswiftPbkdf2hmacsha1(password: Data, salt: Data, iterationCount: Int, keyLength: Int) throws -> Data {
        let pbkdf2: PKCS5.PBKDF2 = try .init(password: password.byteArray, salt: salt.byteArray, iterations: iterationCount, keyLength: keyLength, variant: .sha1)
        let key: [UInt8] = try pbkdf2.calculate()
        return .init(key)
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
    static func QCCAESPadCBCEncrypt(key: [UInt8], iv: [UInt8], plainText: [UInt8]) throws -> [UInt8] {
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
    static func QCCAESPadCBCDecrypt(key: [UInt8], iv: [UInt8], cipherText: [UInt8]) throws -> [UInt8] {
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

// MARK: - Convenience Methods
extension CryptoUtils {
    static func hmacsha256(_ key: Data, _ message: Data) throws -> Data {
        return try hmacsha256(key: key, message: message)
    }

    static func aescbcdecrypt(_ key: Data, _ iv: Data, _ cipherText: Data) throws -> Data {
        return try aescbcdecrypt(key: key, iv: iv, cipherText: cipherText)
    }

    static func aesctrdecrypt(_ key: Data, _ iv: Data, _ cipherText: Data) throws -> Data {
        return try aesctrdecrypt(key: key, iv: iv, cipherText: cipherText)
    }

    static func pbkdf2hmacsha1(_ password: Data, _ salt: Data, _ iterationCount: Int, _ keyLength: Int) throws -> Data {
        return try pbkdf2hmacsha1(password: password, salt: salt, iterationCount: iterationCount, keyLength: keyLength)
    }
}
