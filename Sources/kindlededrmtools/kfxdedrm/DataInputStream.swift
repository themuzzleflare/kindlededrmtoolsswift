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
        self.data = data
        pos = 0
        count = data.count
    }
    
    convenience init(_ data: Data) {
        self.init(data: data)
    }
    
    init(data: Data, offset: Int = 0, length: Int) {
        self.data = data
        pos = offset
        count = min(offset + length, data.count)
        mark = offset
    }
    
    convenience init(_ data: Data, _ offset: Int = 0, _ length: Int) {
        self.init(data: data, offset: offset, length: length)
    }
    
    @discardableResult
    func read() -> UInt8 {
        if pos < count {
            let result: UInt8 = data[pos]
            pos += 1
            return result
        } else {
            return .init(truncatingIfNeeded: -1)
        }
    }
    
    @discardableResult
    func read(data: inout Data, off: Int = 0, len: Int) -> Int {
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
    
    @discardableResult
    func read(_ data: inout Data, _ off: Int = 0, _ len: Int) -> Int {
        return read(data: &data, off: off, len: len)
    }
    
    func readAllBytes() -> Data {
        let result: Data = data.subdata(in: pos..<count)
        
        pos = count
        
        return result
    }
    
    @discardableResult
    func readNBytes(data: inout Data, off: Int = 0, len: Int) -> Int {
        let n: Int = read(data: &data, off: off, len: len)
        
        return n == -1 ? 0 : n
    }
    
    @discardableResult
    func readNBytes(_ data: inout Data, _ off: Int = 0, _ len: Int) -> Int {
        return readNBytes(data: &data, off: off, len: len)
    }
    
    func readNBytes(len: Int) -> Data {
        var result: Data = .init(count: len)
        readNBytes(data: &result, off: 0, len: len)
        return result
    }
    
    func readNBytes(_ len: Int) -> Data {
        return readNBytes(len: len)
    }
    
    @discardableResult
    func skip(n: Int) -> Int {
        var k: Int = count - pos
        
        if n < k {
            k = n < 0 ? 0 : n
        }
        
        pos += k
        
        return k
    }
    
    @discardableResult
    func skip(_ n: Int) -> Int {
        return skip(n: n)
    }
    
    func available() -> Int {
        return count - pos
    }
    
    func markPos() {
        mark = pos
    }
    
    func reset() {
        pos = mark
    }
    
    func tell() -> Int {
        return pos
    }
    
    func seek(position: Int) {
        reset()
        skip(n: position)
    }
    
    func seek(_ position: Int) {
        seek(position: position)
    }
}
