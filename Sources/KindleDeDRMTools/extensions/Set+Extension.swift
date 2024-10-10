//
//  Set+Extension.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 9/10/2024.
//

import Foundation

extension Set where Element == Data {
	var description: String {
		return map(\.formattedForOutput).joined(separator: ",\n")
	}
}

extension Set where Element == Data? {
	var description: String {
		return map(\.formattedForOutput).joined(separator: ",\n")
	}
}
