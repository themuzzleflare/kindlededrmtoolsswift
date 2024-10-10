//
//  ParserState.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

enum ParserState: Int {
	case invalid = 1
	case beforeField
	case beforeTid
	case beforeValue
	case afterValue
	case eof
}

// MARK: - CustomStringConvertible
extension ParserState: CustomStringConvertible {
	var description: String {
		switch self {
		case .invalid:
			return "Invalid"
		case .beforeField:
			return "Before Field"
		case .beforeTid:
			return "Before TID"
		case .beforeValue:
			return "Before Value"
		case .afterValue:
			return "After Value"
		case .eof:
			return "EOF"
		}
	}
}
