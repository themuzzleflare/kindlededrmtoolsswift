//
//  PukallCipher.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

enum PukallCipher {
    static func pc1(key: Data, src: Data, decryption: Bool = true) throws -> Data {
        try validateKeyLength(key: key)
        
        var wkey: [UInt16] = initialiseWKey(key: key)
        var dst: Data = .init(count: src.count)
        
        processSourceArray(src: src, decryption: decryption, wkey: &wkey, dst: &dst)
        
        return dst
    }
    
    private static func validateKeyLength(key: Data) throws {
        if key.count != 16 {
            throw PC1Error.badKeyLength(length: key.count)
        }
    }
    
    private static func initialiseWKey(key: Data) -> [UInt16] {
        var wkey: [UInt16] = .init()
        
        for i in 0..<8 {
            let upper = UInt16(key[i * 2]) << 8
            let lower = UInt16(key[i * 2 + 1])
            wkey.append(upper | lower)
        }
        
        return wkey
    }
    
    private static func processSourceArray(src: Data, decryption: Bool, wkey: inout [UInt16], dst: inout Data) {
        var sum1: UInt32 = 0
        var sum2: UInt32 = 0
        var keyXorVal: UInt16 = 0
        
        for i in 0..<src.count {
            var temp1: UInt32 = 0
            var byteXorVal: UInt16 = 0
            
            for j in 0..<8 {
                temp1 ^= UInt32(wkey[j])
                sum2 = (sum2 + UInt32(j)) * 20021 + sum1
                sum1 = (temp1 * 346) & 0xFFFF
                sum2 = (sum2 + sum1) & 0xFFFF
                temp1 = (temp1 * 20021 + 1) & 0xFFFF
                byteXorVal ^= UInt16(temp1 ^ sum2)
            }
            
            var curByte: UInt8 = src[i]
            
            if !decryption {
                keyXorVal = UInt16(curByte) * 257
            }
            
            curByte = UInt8(((UInt16(curByte) ^ (byteXorVal >> 8)) ^ byteXorVal) & 0xFF)
            
            if decryption {
                keyXorVal = UInt16(curByte) * 257
            }
            
            for j in 0..<8 {
                wkey[j] ^= keyXorVal
            }
            
            dst[i] = curByte
        }
    }
}


// MARK: - Convenience Methods
extension PukallCipher {
    static func pc1(_ key: Data, _ src: Data, _ decryption: Bool = true) throws -> Data {
        return try pc1(key: key, src: src, decryption: decryption)
    }
}
