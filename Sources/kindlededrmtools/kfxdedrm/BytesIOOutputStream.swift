//
//  BytesIOOutputStream.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

final class BytesIOOutputStream {
    private var buf: Data
    
    private var count: Int
    
    init() {
        buf = .init()
        count = 0
    }
    
    func write(b: UInt8) {
        buf[count] = b
        count += 1;
    }
    
    func write(_ b: UInt8){
        write(b: b)
    }
    
    func write(b: Int) {
        write(b: UInt8(b))
    }
    
    func write(_ b: Int) {
        write(b: b)
    }
    
    func write(b: Data, off: Int = 0, len: Int) {
        buf.replaceSubrange(count..<count+len, with: b[off..<off+len])
        count += len;
    }
    
    func write(_ b: Data, _ off: Int = 0, _ len: Int) {
        write(b: b, off: off, len: len)
    }
    
    func writeBytes(b: Data) {
        write(b, 0, b.count);
    }
    
    func writeBytes(_ b: Data) {
        writeBytes(b: b)
    }
    
    func write(b: Data) {
        writeBytes(b: b)
    }
    
    func write(_ b: Data) {
        writeBytes(b: b)
    }
    
    func reset() {
        count = 0
    }
    
    func toData() -> Data {
        return buf.subdata(in: 0..<count)
    }
    
    func size() -> Int {
        return count
    }
    
    
}
