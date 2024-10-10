//
//  MetaDictionary.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
#if canImport(OrderedCollections)
import OrderedCollections
typealias MetaDictionary = OrderedDictionary<Int, Data>
#else
typealias MetaDictionary = [Int: Data]
#endif

extension MetaDictionary {
	var description: String {
		return map({"\($0.description): \($1.formattedForOutput)"}).joined(separator: "\n")
	}
}
