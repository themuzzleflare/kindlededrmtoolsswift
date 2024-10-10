//
//  SymbolToken.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

struct SymbolToken {
	let text: String
	let sid: Int
	
	init(text: String = "", sid: Int = 0) throws {
		if text.isEmpty && sid == 0 {
			throw SymbolTokenError.missingTextAndSid
		}
		
		self.text = text
		self.sid = sid
	}
}

// MARK: - Convenience Initialisers
extension SymbolToken {
	init(_ text: String, _ sid: Int) throws {
		try self.init(text: text, sid: sid)
	}
}
