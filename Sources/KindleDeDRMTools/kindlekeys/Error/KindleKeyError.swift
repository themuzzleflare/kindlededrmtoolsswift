//
//  KindleKeyError.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 8/10/2024.
//

import Foundation
#if canImport(OSInfo)
import OSInfo
#endif

enum KindleKeyError: Error {
	case stringFromDataFailed(data: Data)
	case dataFromStringFailed(string: String)
	case stringToIntFailed(string: String)
	case environmentVariableNotSet(string: String)
	case unknownVersion(version: Int)
	case unsupportedOperatingSystem
	case noKeysFound
	
	var localizedDescription: String {
		switch self {
		case let .stringFromDataFailed(data):
			return "Failed to convert data to string: \(data.formattedForOutput)"
		case let .dataFromStringFailed(string):
			return "Failed to convert string to data: \(string)"
		case let .stringToIntFailed(string):
			return "Failed to convert string to integer: \(string)"
		case let .environmentVariableNotSet(string):
			return "Environment variable not set: \(string)"
		case let .unknownVersion(version):
			return "Unknown version: \(version.description)"
		case .unsupportedOperatingSystem:
#if canImport(OSInfo)
			return "Unsupported operating system: \(OS.current.name)"
#else
			return "Unsupported operating system"
#endif
		case .noKeysFound:
			return "No keys found"
		}
	}
}

// MARK: - LocalizedError
extension KindleKeyError: LocalizedError {
	var errorDescription: String? {
		return localizedDescription
	}
}

// MARK: - CustomStringConvertible
extension KindleKeyError: CustomStringConvertible {
	var description: String {
		return localizedDescription
	}
}
