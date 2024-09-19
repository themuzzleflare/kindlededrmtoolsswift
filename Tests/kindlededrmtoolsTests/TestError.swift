//
//  TestError.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation

enum TestError {
    case pathNotFound
    case dataFromStringFailed
}

// MARK: - LocalizedError
extension TestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .pathNotFound:
            return "File path not found"
        case .dataFromStringFailed:
            return "Failed to create a data representation of string(s)"
        }
    }
}
