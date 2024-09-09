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
        var result = [UInt8]()
        
        for b in data {
            let value = Int(b & 0xFF) // Convert byte to an unsigned integer (0 to 255)
            
            let q = (value ^ 0x80) / charMap.count
            let r = value % charMap.count
            
            result.append(charMap[q])
            result.append(charMap[r])
        }
        
        return Data(result)
    }
    
    // Hash the bytes in data and then encode the digest with the characters in map
    static func encodeHash(data: Data, charMap: Data) -> Data {
        return encode(data: HashUtils.md5(data: data), charMap: charMap)
    }
    
    // Decode the byte array `data` using the byte array `map`. Returns the decoded bytes as a new byte array.
    static func decode(data: Data, map: Data) -> Data {
        var result = [UInt8]()
        
        var i = 0
        while i < data.count - 1 {
            let high = map.firstIndex(of: data[i]) ?? -1
            let low = map.firstIndex(of: data[i + 1]) ?? -1
            
            if high == -1 || low == -1 {
                break
            }
            
            let value = UInt8((((high * map.count) ^ 0x80) & 0xFF) + low)
            result.append(value)
            
            i += 2
        }
        
        return Data(result)
    }
    
    public static func checksumPid(data: String, charMap: Data) -> String {
        guard let dataBytes = data.data(using: .utf8) else {
            return ""
        }
        
        return String(data: checksumPid(data: dataBytes, charMap: charMap), encoding: .utf8) ?? ""
    }
    
    public static func checksumPid(data: Data, charMap: Data) -> Data {
        var crc = Int(crc32(data: data))
        
        crc = crc ^ (crc >> 16)
        
        var output = data
        
        for _ in 0..<2 {
            let b = crc & 0xff
            let pos = (b / charMap.count) ^ (b % charMap.count)
            
            output.append(charMap[pos % charMap.count])
            
            crc >>= 8
        }
        
        return output
    }
    
    static func crc32(data: Data) -> Int64 {
        return Int64(zlibcrc32(data: .init(data)))
    }
    
    private static func zlibcrc32(data: [UInt8]) -> UInt32 {
        return ~UInt32(zlib.crc32(uLong.max, data, uInt(data.count)))
    }
}
