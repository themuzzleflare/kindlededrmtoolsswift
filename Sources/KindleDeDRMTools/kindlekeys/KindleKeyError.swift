//
//  KindleKeyError.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 8/10/2024.
//

import Foundation

enum KindleKeyError {
    case stringFromDataFailed(data: Data)
    case dataFromStringFailed(string: String)
    case stringToIntFailed(string: String)
    case noKeysFound
}

// MARK: - LocalizedError
extension KindleKeyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .stringFromDataFailed(data):
            return "Failed to convert data to string: \(data.formattedForOutput)"
        case let .dataFromStringFailed(string):
            return "Failed to convert string to data: \(string)"
        case let .stringToIntFailed(string):
            return "Failed to convert string to integer: \(string)"
        case .noKeysFound:
            return "No keys found"
        }
    }
}
