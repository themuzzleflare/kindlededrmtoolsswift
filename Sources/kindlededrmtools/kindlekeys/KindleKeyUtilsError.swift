//
//  KindleKeyUtilsError.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 16/9/2024.
//

import Foundation

enum KindleKeyUtilsError {
    case dataFromStringFailed(string: String)
}

// MARK: - LocalizedError
extension KindleKeyUtilsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .dataFromStringFailed(string):
            return "Failed to convert string to data: \(string)"
        }
    }
}
