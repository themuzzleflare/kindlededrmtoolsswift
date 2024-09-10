//
//  CharMaps.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation

enum CharMaps {
    static let charMap1: Data = "n5Pr6St7Uv8Wx9YzAb0Cd1Ef2Gh3Jk4M".data(using: .ascii)!
    static let charMap3: Data = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".data(using: .ascii)!
    static let charMap4: Data = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789".data(using: .ascii)!
    static let testMap8: Data = "YvaZ3FfUm9Nn_c1XuG4yCAzB0beVg-TtHh5SsIiR6rJjQdW2wEq7KkPpL8lOoMxD".data(using: .ascii)!
    static let asteriskBytes: Data = "*".data(using: .ascii)!
    static let letters: Data = charMap4
    static let bookmobiBytes: Data = "BOOKMOBI".data(using: .ascii)!
    static let textreadBytes: Data = "TEXtREAd".data(using: .ascii)!
    static let mopBytes: Data = "%MOP".data(using: .ascii)!
    static let exthBytes: Data = "EXTH".data(using: .ascii)!
    static let kfxDrmIonBytes: Data = .init([0xEA, 0x44, 0x52, 0x4D, 0x49, 0x4F, 0x4E, 0xEE])
    static let voucherBytes: Data = .init([0xe0, 0x01, 0x00, 0xea])
    static let protectedDataBytes: Data = "ProtectedData".data(using: .ascii)!
    static let topazBytes: Data = "TPZ".data(using: .ascii)!
    static let pkBytes: Data = .init([0x50, 0x4B, 0x03, 0x04])
    static let pidv3Bytes: Data = "PIDv3".data(using: .ascii)!
}
