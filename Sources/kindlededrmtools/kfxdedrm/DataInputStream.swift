//
//  DataInputStream.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

final class DataInputStream {
    private let data: Data
    
    private var pos: Int
    private var mark: Int = 0
    private var count: Int
    
    init(data: Data) {
        Debug.print("DataInputStream.", #function, separator: "")
        
        self.data = data
        pos = 0
        count = data.count
    }
    
    init(data: Data, offset: Int = 0, length: Int) {
        Debug.print("DataInputStream.", #function, separator: "")
        
        self.data = data
        pos = offset
        count = min(offset + length, data.count)
        mark = offset
    }
    
    convenience init(_ data: Data) {
        Debug.print("DataInputStream.", #function, separator: "")
        
        self.init(data: data)
    }
    
    func read() -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        if pos < count {
            pos += 1
            return .init(data[pos] & 0xff)
        } else {
            return -1
        }
    }
    
    @discardableResult
    func read(data: inout Data, off: Int = 0, len: Int) -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        var len: Int = len
        
        if pos >= count {
            return -1
        }
        
        let avail: Int = count - pos
        
        if len > avail {
            len = avail
        }
        
        if len <= 0 {
            return 0
        }
        
        for i in 0..<len {
            data[off + i] = self.data[pos + i]
        }
        
        pos += len
        
        return len
    }
    
    func readAllBytes() -> Data {
        Debug.print("DataInputStream.", #function, separator: "")
        
        let result: Data = data.subdata(in: pos..<count)
        
        pos = count
        
        return result
    }
    
    @discardableResult
    func readNBytes(data: inout Data, off: Int = 0, len: Int) -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        let n: Int = read(data: &data, off: off, len: len)
        return n == -1 ? 0 : n
    }
    
    func readNBytes(len: Int) -> Data {
        Debug.print("DataInputStream.", #function, separator: "")
        
        var result: Data = .init(count: len)
        readNBytes(data: &result, off: 0, len: len)
        return result
    }
    
    func readNBytes(_ len: Int) -> Data {
        Debug.print("DataInputStream.", #function, separator: "")
        
        return readNBytes(len: len)
    }
    
    @discardableResult
    func skip(n: Int64) -> Int64 {
        Debug.print("DataInputStream.", #function, separator: "")
        
        var k: Int64 = .init(count - pos)
        
        if n < k {
            k = n < 0 ? 0 : n
        }
        
        pos += .init(k)
        
        return k
    }
    
    @discardableResult
    func skip(_ n: Int) -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        return .init(skip(n: .init(n)))
    }
    
    func available() -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        return count - pos
    }
    
    func markPos() {
        Debug.print("DataInputStream.", #function, separator: "")
        
        mark = pos
    }
    
    func reset() {
        Debug.print("DataInputStream.", #function, separator: "")
        
        pos = mark
    }
    
    func tell() -> Int {
        Debug.print("DataInputStream.", #function, separator: "")
        
        return pos
    }
    
    func seek(position: Int) {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        reset()
        skip(n: .init(position))
    }
}
