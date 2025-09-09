//
//  KindleKeyUtilsTests.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation
import XCTest
@testable import KindleDeDRMTools

final class KindleKeyUtilsTests: XCTestCase {
    func testCrc32() throws {
        let pid1: Data = "vCNIml/c".data(using: .ascii)!
        let pid2: Data = "JBJfi+Wm".data(using: .ascii)!
        let pid3: Data = "5m9pZCYO".data(using: .ascii)!
        let pid4: Data = "bEQyy4Rz".data(using: .ascii)!
        let pid5: Data = "EGnqh3QS".data(using: .ascii)!
        
        let expected1: Int64 = 827044802
        let expected2: Int64 = 1740101228
        let expected3: Int64 = 2795348181
        let expected4: Int64 = 3135611226
        let expected5: Int64 = 2682308693
        
        let result1: Int64 = KindleKeyUtils.crc32(data: pid1)
        let result2: Int64 = KindleKeyUtils.crc32(data: pid2)
        let result3: Int64 = KindleKeyUtils.crc32(data: pid3)
        let result4: Int64 = KindleKeyUtils.crc32(data: pid4)
        let result5: Int64 = KindleKeyUtils.crc32(data: pid5)
        
        XCTAssertEqual(expected1, result1)
        XCTAssertEqual(expected2, result2)
        XCTAssertEqual(expected3, result3)
        XCTAssertEqual(expected4, result4)
        XCTAssertEqual(expected5, result5)
    }
}
