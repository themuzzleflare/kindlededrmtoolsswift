//
//  MobiBookError.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

enum MobiBookError {
    case urlCreationFiled(string: String)
    case invalidFileFormat(data: Data)
    case unknownEncryptionType(type: Int)
    case encryptionNotInitialised
    case noKeyFound(pidsSize: Int)
}

// MARK: - LocalizedError
extension MobiBookError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .urlCreationFiled(string):
            return "Failed to create URL representing path: \(string)"
        case let .invalidFileFormat(data):
            return "Invalid file format: \(data.formattedForOutput)"
        case let .unknownEncryptionType(type):
            return "Cannot decode unknown Mobipocket encryption type: \(type.description)"
        case .encryptionNotInitialised:
            return "Encryption not initialised. Must be opened with Mobipocket Reader first."
        case let .noKeyFound(pidsSize):
            return "No key found in \(pidsSize.description) PIDs tried."
        }
    }
}
