//
//  DRMInfo.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation

struct DRMInfo {
	let key: Data?
	let pid: String
	
	init(key: Data?, pid: String) {
		self.key = key
		self.pid = pid
	}
}

// MARK: - CustomStringConvertible
extension DRMInfo: CustomStringConvertible {
	var description: String {
		return "(key: \(key.formattedForOutput), pid: \(pid))"
	}
}

// MARK: - Convenience Initialisers
extension DRMInfo {
	init(_ key: Data?, _ pid: String) {
		self.init(key: key, pid: pid)
	}
}
