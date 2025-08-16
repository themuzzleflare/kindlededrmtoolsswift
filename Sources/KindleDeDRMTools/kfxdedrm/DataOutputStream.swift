//
//  DataOutputStream.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

final class DataOutputStream {
    private var data: Data = .init()
    private var count: Int = 0
    
    func write(byte: UInt8) {
        data.append(byte)
        count += 1
    }
    
    func write(int: Int) {
        write(byte: UInt8(int))
    }
    
    func write(data: Data, off: Int = 0, len: Int) {
        self.data.append(data.subdata(in: off..<len))
        count += len
    }
    
    func writeBytes(data: Data) {
        write(data, 0, data.count)
    }
    
    func write(data: Data) {
        writeBytes(data: data)
    }
    
    func reset() {
        count = 0
    }
    
    func toData() -> Data {
        return data.subdata(in: 0..<count)
    }
    
    func size() -> Int {
        return count
    }
}

// MARK: - Convenience Methods
extension DataOutputStream {
    func write(_ byte: UInt8) {
        write(byte: byte)
    }
    
    func write(_ int: Int) {
        write(int: int)
    }
    
    func write(_ data: Data, _ off: Int = 0, _ len: Int) {
        write(data: data, off: off, len: len)
    }
    
    func writeBytes(_ data: Data) {
        writeBytes(data: data)
    }
    
    func write(_ data: Data) {
        write(data: data)
    }
}
