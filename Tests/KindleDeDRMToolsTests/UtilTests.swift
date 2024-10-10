//
//  UtilTests.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation
import Testing
@testable import KindleDeDRMTools

@Suite("Util Tests")
struct UtilTests {
	@Test("formatData Test") func testFormatData() {
		let bytes1: Data = .init([0xEA, 68, 82, 77, 73, 79, 78, 0xEE])
		let bytes2: Data = .init([84, 80, 90])
		let bytes3: Data = .init([80, 75, 0x03, 0x04])
		
		let expected1: String = "b'\\xeaDRMION\\xee'"
		let expected2: String = "b'TPZ'"
		let expected3: String = "b'PK\\x03\\x04'"
		
		let result1: String = Util.formatData(data: bytes1)
		let result2: String = Util.formatData(data: bytes2)
		let result3: String = Util.formatData(data: bytes3)
		
		#expect(expected1 == result1)
		#expect(expected2 == result2)
		#expect(expected3 == result3)
	}
}
