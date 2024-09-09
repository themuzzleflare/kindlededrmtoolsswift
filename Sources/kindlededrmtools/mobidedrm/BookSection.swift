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
}

extension BookSection: CustomStringConvertible {
    var description: String {
        return "(offset: \(offset.description), flags: \(flags.description), val: \(val.description))"
    }
}

//extension Array where Element == BookSection {
//  var description: String {
//    return self.map { section in
//      return section.description
//    }.joined(separator: "\n")
//  }
//}
