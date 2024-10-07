//
//  OrderedSet+Extension.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

import Foundation
import OrderedCollections

extension OrderedSet where Element == Data {
    var description: String {
        return map(\.formattedForOutput).joined(separator: ",\n")
    }
}

extension OrderedSet where Element == Data? {
    var description: String {
        return map(\.formattedForOutput).joined(separator: ",\n")
    }
}
