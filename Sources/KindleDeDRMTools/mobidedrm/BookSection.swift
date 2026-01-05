//
//  BookSection.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

struct BookSection {
    let offset: UInt32
    let flags: UInt8
    let val: UInt32

    init(offset: UInt32, flags: UInt8, val: UInt32) {
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
    init(_ offset: UInt32, _ flags: UInt8, _ val: UInt32) {
        self.init(offset: offset, flags: flags, val: val)
    }
}
