//
//  MetaDictionary.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import OrderedCollections

typealias MetaDictionary = OrderedDictionary<Int, Data>

extension MetaDictionary {
    var description: String {
        return map({"\($0.description): \($1.formattedForOutput)"}).joined(separator: "\n")
    }
}
