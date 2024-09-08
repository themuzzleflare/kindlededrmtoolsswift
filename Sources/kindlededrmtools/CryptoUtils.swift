//
//  CryptoUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CryptoKit
import CommonCrypto

final class CryptoUtils {
  private init() {}
  
  /**
   * Computes the HMAC-SHA256 hash of the given message using the provided key.
   * - Parameters:
   *   - key: The key to use for the HMAC.
   *   - message: The message to hash.
   * - Returns: The HMAC-SHA256 hash of the message as `Data`.
   */
  public static func hmacsha256(key: Data, message: Data) -> Data {
    let keySymmetric = SymmetricKey(data: key)
    let authenticationCode = HMAC<SHA256>.authenticationCode(for: message, using: keySymmetric)
    return Data(authenticationCode)
  }
  
  /**
   * Decrypts the given ciphertext using AES/CBC with the provided key and IV.
   * - Parameters:
   *   - key: The key to use for AES/CBC decryption.
   *   - iv: The initialization vector.
   *   - cipherText: The encrypted data.
   * - Returns: The decrypted data as `Data`.
   */
  public static func aescbcdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
    // The key size must be 128, 192, or 256.
    // The IV size must match the block size.
    // The ciphertext must be a multiple of the block size.
    
    guard
      [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(key.count),
      iv.count == kCCBlockSizeAES128,
      cipherText.count.isMultiple(of: kCCBlockSizeAES128)
    else {
      throw QCCError(code: kCCParamError)
    }
    
    // Padding can expand the data on encryption, but on decryption the data can
    // only shrink so we use the cyphertext size as our plaintext size.
    
    var plaintext: [UInt8] = .init(repeating: 0, count: cipherText.count)
    var plaintextCount = 0
    
    let err = CCCrypt(
      CCOperation(kCCDecrypt),
      CCAlgorithm(kCCAlgorithmAES),
      CCOptions(kCCOptionPKCS7Padding),
      [UInt8](key), key.count,
      [UInt8](iv),
      [UInt8](cipherText), cipherText.count,
      &plaintext, plaintext.count,
      &plaintextCount
    )
    
    guard err == kCCSuccess else {
      throw QCCError(code: err)
    }
    
    // Trim any unused bytes off the plaintext.
    assert(plaintextCount <= plaintext.count)
    plaintext.removeLast(plaintext.count - plaintextCount)
    
    return Data(plaintext)
  }
  
  /**
   * Decrypts the given ciphertext using AES/CTR with the provided key and IV.
   * - Parameters:
   *   - key: The key to use for AES/CTR decryption.
   *   - iv: The initialization vector.
   *   - cipherText: The encrypted data.
   * - Returns: The decrypted data as `Data`.
   */
  public static func aesctrdecrypt(key: Data, iv: Data, cipherText: Data) throws -> Data {
    let keySymmetric = SymmetricKey(data: key)
    let nonce = try AES.GCM.Nonce(data: iv)
    let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: cipherText, tag: Data())
    let decryptedData = try AES.GCM.open(sealedBox, using: keySymmetric)
    return decryptedData
  }
}
