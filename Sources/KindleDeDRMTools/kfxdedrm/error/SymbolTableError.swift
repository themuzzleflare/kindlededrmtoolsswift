//
//  SymbolTableError.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

enum SymbolTableError {
    case invalidSymbolId(id: Int)
}

// MARK: - LocalizedError
extension SymbolTableError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .invalidSymbolId(id):
            return "Invalid Symbol ID: \(id.description)"
        }
    }
}
