//
//  IonUtilsError.swift
//
//
//  Created by Paul Tavitian on 12/9/2024.
//

import Foundation

enum IonUtilsError {
    case obfuscationValueNotFound(key: String)
}

extension IonUtilsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .obfuscationValueNotFound(key):
            return "Obfuscation value not found for key: \(key)"
        }
    }
}
