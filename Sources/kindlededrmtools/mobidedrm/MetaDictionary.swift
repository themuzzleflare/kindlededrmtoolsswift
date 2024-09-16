//
//  MetaDictionary.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import Collections

typealias MetaDictionary = OrderedDictionary<Int, Data>

extension MetaDictionary {
    var description: String {
        return map { key, value in
            return "\(key): \(Util.formatData(data: value))"
        }.joined(separator: "\n")
    }
}
