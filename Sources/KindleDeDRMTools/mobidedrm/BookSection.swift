//
//  BookSection.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

struct BookSection {
    let offset: Int
    let flags: Int
    let val: Int
    
    init(offset: Int, flags: Int, val: Int) {
        self.offset = offset
        self.flags = flags
        self.val = val
    }
}

// MARK: - CustomStringConvertible
extension BookSection: CustomStringConvertible {
    var description: String {
        return "(offset: \(offset.description), flags: \(flags.description), val: \(val.description))"
    }
}

// MARK: - Convenience Initialisers
extension BookSection {
    init(_ offset: Int, _ flags: Int, _ val: Int) {
        self.init(offset: offset, flags: flags, val: val)
    }
    
    init(offset: Int, flags: UInt8, val: Int) {
        self.init(offset: offset, flags: Int(flags), val: val)
    }
    
    init(_ offset: Int, _ flags: UInt8, _ val: Int) {
        self.init(offset: offset, flags: flags, val: val)
    }
}
