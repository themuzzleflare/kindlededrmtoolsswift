//
//  Util.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import Collections

enum Util {
    static let copyright: String = "Copyright © 2024 Paul Tavitian"
    
    static func formatData(data: Data?) -> String {
        guard let data else {
            return "b''"
        }
        
        var result: String = "b'"
        
        for byte in data {
            if byte >= 32 && byte <= 126 {  // Printable ASCII range
                let scalar: UnicodeScalar = .init(byte)
                result.append(Character(scalar))
            } else {  // Non-printable range, use \x escape
                result.append(.init(format: "\\x%02x", byte))
            }
        }
        
        result.append("'")
        
        return result
    }
    
    /**
     Left-justifies a Data object to a specified width and pads with a given byte.
     
     - Parameters:
     - data: The `Data` object to left-justify.
     - width: The desired width of the resulting `Data` object.
     - padByte: The byte to use for padding.
     - Returns: A new `Data` object of the specified width, with `data` left-justified and padded with `padByte`.
     */
    static func ljustBytes(data: Data?, width: Int, padByte: UInt8) -> Data {
        // If data is nil, create a new Data object of 'width' size filled with 'padByte'
        guard let data else {
            return .init(repeating: padByte, count: width)
        }
        
        // If the original data is already long enough, return it as is
        if data.count >= width {
            return data
        }
        
        // Create a mutable copy of the data
        var result: Data = data
        
        // Append the padding bytes to the result
        result.append(.init(repeating: padByte, count: width - data.count))
        
        return result
    }
    
    /**
     Calculates the checksum of a `Data` object by summing its bytes.
     
     - Parameter data: The `Data` object to calculate the sum of.
     - Returns: The checksum of the byte array as an `Int`.
     */
    static func sumBytes(data: Data?) -> Int {
        // If data is nil, return 0
        guard let data else {
            return 0
        }
        
        var sum: Int = 0
        
        // Iterate over each byte and add to the sum, treating each byte as an unsigned value
        for byte in data {
            sum += .init(byte)
        }
        
        // Apply & 0xFF to keep the result within 8 bits
        return sum & 0xFF
    }
    
    static func ord(data: Data) -> Int {
        return .init(data[0] & 0xFF)
    }
    
    static func ordList(data: Data?) -> [Int] {
        guard let data else {
            return .init()
        }
        
        var list: [Int] = .init()
        
        for byte in data {
            list.append(ord(.init([byte])))
        }
        
        return list
    }
    
    static func padBytes(data: Data?, blocklen: Int, padByte: UInt8 = 0) -> Data {
        guard let data else {
            return .init(repeating: padByte, count: blocklen)
        }
        
        if data.count.isMultiple(of: blocklen) {
            return data
        }
        
        let padding: Int = blocklen - (data.count % blocklen)
        return data + .init(repeating: padByte, count: padding)
    }
    
    static func practicalIsEmpty(set: OrderedSet<String>?) -> Bool {
        guard let set else {
            return true
        }
        
        return set.isEmpty || set.allSatisfy({$0.isEmpty})
    }
    
    static func sanitiseSet(set: OrderedSet<String>?) -> OrderedSet<String> {
        guard let set else {
            return .init()
        }
        
        if practicalIsEmpty(set) {
            return .init()
        }
        
        return .init(set.map({$0.trimmingCharacters(in: .whitespaces)})).filter({!$0.isEmpty})
    }
    
    static func hexStringToData(hexString: String?) -> Data? {
        guard let hexString else {
            return nil
        }
        
        guard hexString.count % 2 == 0 else {
            return nil
        }
        
        var data: Data = .init()
        var index: String.Index = hexString.startIndex
        
        // Loop through the string two characters at a time
        while index < hexString.endIndex {
            let nextIndex: String.Index = hexString.index(index, offsetBy: 2)
            let hexPair: Substring = hexString[index..<nextIndex]
            
            // Convert the hex pair to a byte
            if let byte: UInt8 = .init(hexPair, radix: 16) {
                data.append(byte)
            } else {
                // Return nil if the hex pair is invalid
                return nil
            }
            
            index = nextIndex
        }
        
        return data
    }
}

// MARK: - Convenience Functions
extension Util {
    static func formatData(_ data: Data?) -> String {
        return formatData(data: data)
    }
    
    static func ord(_ data: Data) -> Int {
        return ord(data: data)
    }
    
    static func ordList(_ data: Data?) -> [Int] {
        return ordList(data: data)
    }
    
    static func practicalIsEmpty(_ set: OrderedSet<String>?) -> Bool {
        return practicalIsEmpty(set: set)
    }
    
    static func sanitiseSet(_ set: OrderedSet<String>?) -> OrderedSet<String> {
        return sanitiseSet(set: set)
    }
    
    static func hexStringToData(_ hexString: String?) -> Data? {
        return hexStringToData(hexString: hexString)
    }
}
