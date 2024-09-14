//
//  DataInputStreamError.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

enum DataInputStreamError {
    case posGreaterThanOrEqualToCount
    case lenLessThanOrEqualToZero
}

extension DataInputStreamError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .posGreaterThanOrEqualToCount:
            return "pos >= count"
        case .lenLessThanOrEqualToZero:
            return "len <= 0"
        }
    }
}
