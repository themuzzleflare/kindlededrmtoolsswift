//
//  SymbolTokenError.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

enum SymbolTokenError {
	case missingTextAndSid
}

// MARK: - LocalizedError
extension SymbolTokenError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .missingTextAndSid:
			return "Symbol token must have either Text or SID"
		}
	}
}
