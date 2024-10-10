//
//  DeDRMError.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation

enum DeDRMError {
	case urlCreationFailed(string: String)
	case noVoucher
}

// MARK: - LocalizedError
extension DeDRMError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .urlCreationFailed(string):
			return "URL creation failed for string: \(string)"
		case .noVoucher:
			return "The .kfx DRMION file cannot be decrypted by itself. A .kfx-zip archive containing a DRM voucher is required."
		}
	}
}
