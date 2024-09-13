//
//  BytesIOInputStream.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

final class BytesIOInputStream {
    private let buf: Data
    
    private var pos: Int
    private var mark: Int = 0
    private var count: Int
    
    init(buf: Data) {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        self.buf = buf
        pos = 0
        count = buf.count
    }
    
    init(buf: Data, offset: Int = 0, length: Int) {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        self.buf = buf
        pos = offset
        count = min(offset + length, buf.count)
        mark = offset
    }
    
    convenience init(_ buf: Data) {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        self.init(buf: buf)
    }
    
    func read() -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        if pos < count {
            pos += 1
            return .init(buf[pos] & 0xff)
        } else {
            return -1
        }
    }
    
    @discardableResult
    func read(data: inout Data, off: Int = 0, len: Int) -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
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
            data[off + i] = buf[pos + i]
        }
        
        pos += len
        
        return len
    }
    
    func readAllBytes() -> Data {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        let result: Data = buf.subdata(in: pos..<count)
        
        pos = count
        
        return result
    }
    
    @discardableResult
    func readNBytes(b: inout Data, off: Int = 0, len: Int) -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        let n: Int = read(data: &b, off: off, len: len)
        return n == -1 ? 0 : n
    }
    
    func readNBytes(len: Int) -> Data {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        var result: Data = .init()
        readNBytes(b: &result, off: 0, len: len)
        return result
    }
    
    func readNBytes(_ len: Int) -> Data {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        return readNBytes(len: len)
    }
    
    @discardableResult
    func skip(n: Int64) -> Int64 {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        var k: Int64 = .init(count - pos)
        
        if n < k {
            k = n < 0 ? 0 : n
        }
        
        pos += .init(k)
        
        return k
    }
    
    @discardableResult
    func skip(_ n: Int) -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        return .init(skip(n: .init(n)))
    }
    
    func available() -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        return count - pos
    }
    
    func markPos() {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        mark = pos
    }
    
    func reset() {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        pos = mark
    }
    
    func tell() -> Int {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        return pos
    }
    
    func seek(position: Int) {
        Debug.print("BytesIOInputStream.", #function, separator: "")
        
        reset()
        skip(n: .init(position))
    }
}
