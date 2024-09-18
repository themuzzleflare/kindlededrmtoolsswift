//
//  KindleKeyUtilsTests.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation
import Testing
@testable import kindlededrmtools

@Suite("KindleKeyUtils Tests")
struct KindleKeyUtilsTests {
    @Test("CRC32 Test") func testcrc32() throws {
        guard let pid1: Data = "vCNIml/c".data(using: .ascii),
              let pid2: Data = "JBJfi+Wm".data(using: .ascii),
              let pid3: Data = "5m9pZCYO".data(using: .ascii),
              let pid4: Data = "bEQyy4Rz".data(using: .ascii),
              let pid5: Data = "EGnqh3QS".data(using: .ascii) else {
            throw TestError.dataFromStringFailed
        }
        
        let crc321Expected: Int64 = 827044802
        let crc322Expected: Int64 = 1740101228
        let crc323Expected: Int64 = 2795348181
        let crc324Expected: Int64 = 3135611226
        let crc325Expected: Int64 = 2682308693
        
        let crc321: Int64 = KindleKeyUtils.crc32(data: pid1)
        let crc322: Int64 = KindleKeyUtils.crc32(data: pid2)
        let crc323: Int64 = KindleKeyUtils.crc32(data: pid3)
        let crc324: Int64 = KindleKeyUtils.crc32(data: pid4)
        let crc325: Int64 = KindleKeyUtils.crc32(data: pid5)
        
        #expect(crc321Expected == crc321)
        #expect(crc322Expected == crc322)
        #expect(crc323Expected == crc323)
        #expect(crc324Expected == crc324)
        #expect(crc325Expected == crc325)
    }
}
