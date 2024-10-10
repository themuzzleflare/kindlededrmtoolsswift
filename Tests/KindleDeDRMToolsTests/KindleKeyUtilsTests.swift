//
//  KindleKeyUtilsTests.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation
import Testing
@testable import KindleDeDRMTools

@Suite("KindleKeyUtils Tests")
struct KindleKeyUtilsTests {
	@Test("CRC32 Test") func testCrc32() throws {
		let pid1: Data = try #require("vCNIml/c".data(using: .ascii))
		let pid2: Data = try #require("JBJfi+Wm".data(using: .ascii))
		let pid3: Data = try #require("5m9pZCYO".data(using: .ascii))
		let pid4: Data = try #require("bEQyy4Rz".data(using: .ascii))
		let pid5: Data = try #require("EGnqh3QS".data(using: .ascii))
		
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
		
		#expect(expected1 == result1)
		#expect(expected2 == result2)
		#expect(expected3 == result3)
		#expect(expected4 == result4)
		#expect(expected5 == result5)
	}
}
