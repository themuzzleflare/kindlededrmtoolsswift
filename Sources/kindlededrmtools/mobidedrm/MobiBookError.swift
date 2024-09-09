//
//  MobiBookError.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

enum MobiBookError {
    case urlCreationFiled
    case invalidFileFormat(data: Data)
    case drmParseFailed
    case unknownEncryptionType(type: Int)
    case encryptionNotInitialised
    case noKeyFound(pids: Int)
}

extension MobiBookError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlCreationFiled:
            return "Failed to create URL representing input file path."
        case let .invalidFileFormat(data):
            return "Invalid File Format: \(Util.formatData(data: data))."
        case .drmParseFailed:
            return "DRM parse failed."
        case let .unknownEncryptionType(type):
            return "Cannot decode unknown Mobipocket encryption type: \(type)"
        case .encryptionNotInitialised:
            return "Encryption not initialised. Must be opened with Mobipocket Reader first."
        case let .noKeyFound(pids):
            return "No key found in \(pids.description) PIDs tried."
        }
    }
}
