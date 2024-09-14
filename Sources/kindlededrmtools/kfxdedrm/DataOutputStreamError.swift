//
//  DataOutputStreamError.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

enum DataOutputStreamError {
    case negativeInitialSize(size: Int)
}

extension DataOutputStreamError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .negativeInitialSize(size):
            return "Negative initial size: \(size.description)"
        }
    }
}
