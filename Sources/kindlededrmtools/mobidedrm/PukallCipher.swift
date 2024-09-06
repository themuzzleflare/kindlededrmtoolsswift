//
//  File.swift
//  
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

final class PukallCipher {
  private init() {}
  
  public static func pc1(key: Data, src: Data, decryption: Bool = true) throws -> Data {
    try validateKeyLength(key: key)
    
    var wkey: Data = initialiseWKey(key: key)
    var dst: Data = .init(capacity: src.count)
    
    processSourceArray(src: src, decryption: decryption, wkey: &wkey, dst: &dst)
    
    return dst
  }
  
  private static func validateKeyLength(key: Data) throws {
    if key.count != 16 {
      throw PC1Error.badKeyLength(length: key.count)
    }
  }
  
  private static func initialiseWKey(key: Data) -> Data {
    var wkey: Data = .init(capacity: 8)
    
    for i in (0..<8) {
      wkey[i] = key[i * 2] << 8 | key[i * 2 + 1]
    }
    
    return wkey
  }
  
  private static func processSourceArray(src: Data, decryption: Bool, wkey: inout Data, dst: inout Data) {
    var sum1 = 0
    var sum2 = 0
    var keyXorVal = 0
    
    for i in (0..<src.count) {
      var temp1 = 0
      var byteXorVal = 0
      
      for j in (0..<8) {
        temp1 ^= wkey[j]
        sum2 = (sum2 + j) * 20021 + sum1
        sum1 = (temp1 * 346) & 0xFFFF
        sum2 = (sum2 + sum1) & 0xFFFF
        temp1 = (temp1 * 20021 + 1) & 0xFFFF
        byteXorVal ^= temp1 ^ sum2
      }
      
      var curByte = src[i]
      
      if !decryption {
        keyXorVal = curByte * 257
      }
      
      curByte = ((curByte ^ (byteXorVal >> 8)) ^ byteXorVal) & 0xFF
      
      if decryption {
        keyXorVal = curByte * 257
      }
      
      for j in (0..<8) {
        wkey[j] ^= keyXorVal
      }
      
      dst[i] = curByte
    }
  }
}
