//
//  TestError.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation

enum TestError {
    case pathNotFound
}

extension TestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .pathNotFound:
            return "File path not found"
        }
    }
}
