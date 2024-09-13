//
//  BytesIOOutputStreamError.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

enum BytesIOOutputStreamError {
    case negativeInitialSize(size: Int)
}

extension BytesIOOutputStreamError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .negativeInitialSize(size):
            return "Negative initial size: \(size.description)"
        }
    }
}
