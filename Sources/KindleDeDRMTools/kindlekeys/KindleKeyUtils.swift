//
//  KindleKeyUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import zlib

final class KindleKeyUtils {
	private init() {}
	
	static func encode(data: Data, charMap: Data) -> Data {
		var result: Data = .init()
		
		for char in data {
			let value: Int = .init(char & 0xFF) // Convert byte to an unsigned integer (0 to 255)
			
			let q: Int = (value ^ 0x80) / charMap.count
			let r: Int = value % charMap.count
			
			result.append(charMap[q])
			result.append(charMap[r])
		}
		
		return result
	}
	
	// Hash the bytes in data and then encode the digest with the characters in map
	static func encodeHash(data: Data?, charMap: Data) -> Data {
		return encode(data: HashUtils.md5(data: data), charMap: charMap)
	}
	
	// Decode the byte array `data` using the byte array `map`. Returns the decoded bytes as a new byte array.
	static func decode(data: Data, map: Data) -> Data {
		var result: Data = .init()
		
		var i: Int = 0
		
		while i < data.count - 1 {
			let high: Data.Index? = map.firstIndex(of: data[i])
			let low: Data.Index? = map.firstIndex(of: data[i + 1])
			
			guard let high, let low else {
				break
			}
			
			let value: UInt8 = .init((((high * map.count) ^ 0x80) & 0xFF) + low)
			result.append(value)
			
			i += 2
		}
		
		return result
	}
	
	static func checksumPid(data: String, charMap: Data) throws -> String {
		guard let dataBytes: Data = data.data(using: .utf8) else {
			throw KindleKeyUtilsError.dataFromStringFailed(string: data)
		}
		
		return .init(data: checksumPid(data: dataBytes, charMap: charMap), encoding: .utf8) ?? ""
	}
	
	static func checksumPid(data: Data, charMap: Data) -> Data {
		var crc: Int = .init(crc32(data: data))
		
		crc ^= (crc >> 16)
		
		var output: Data = data
		
		for _ in 0..<2 {
			let b: Int = crc & 0xff
			let pos: Int = (b / charMap.count) ^ (b % charMap.count)
			
			output.append(charMap[pos % charMap.count])
			
			crc >>= 8
		}
		
		return output
	}
	
	static func crc32(data: Data) -> Int64 {
		return .init(zlibcrc32(data: .init(data)))
	}
	
	private static func zlibcrc32(data: [UInt8]) -> UInt32 {
		return ~.init(zlib.crc32(.max, data, .init(data.count)))
	}
}

// MARK: - Convenience Methods
extension KindleKeyUtils {
	static func encode(_ data: Data, _ charMap: Data) -> Data {
		return encode(data: data, charMap: charMap)
	}
	
	static func encodeHash(_ data: Data?, _ charMap: Data) -> Data {
		return encodeHash(data: data, charMap: charMap)
	}
	
	static func decode(_ data: Data, _ map: Data) -> Data {
		return decode(data: data, map: map)
	}
	
	static func checksumPid(_ data: String, _ charMap: Data) throws -> String {
		return try checksumPid(data: data, charMap: charMap)
	}
	
	static func checksumPid(_ data: Data, _ charMap: Data) -> Data {
		return checksumPid(data: data, charMap: charMap)
	}
	
	static func crc32(_ data: Data) -> Int64 {
		return crc32(data: data)
	}
}
