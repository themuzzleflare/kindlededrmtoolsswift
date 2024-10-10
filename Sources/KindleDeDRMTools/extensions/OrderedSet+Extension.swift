//
//  OrderedSet+Extension.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

import Foundation
#if canImport(OrderedCollections)
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
#endif
