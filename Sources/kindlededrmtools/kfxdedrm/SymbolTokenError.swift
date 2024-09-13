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

extension SymbolTokenError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingTextAndSid:
            return "Symbol token must have Text or SID"
        }
    }
}
