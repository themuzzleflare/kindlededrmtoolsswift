//
//  DRMIonVoucherError.swift
//
//
//  Created by Paul Tavitian on 12/9/2024.
//

import Foundation

enum DRMIonVoucherError {
	case dataFromStringFailed(string: String)
	case unknownLockParameter(string: String)
	case expectedKeySet(found: String)
	case unknownDecryptionError
	case unknownCipherAlgorithm(string: String)
	case unknownKeyFormat(string: String)
	case envelopeEmpty
	case voucherEmpty
	case unknownTypeExpectedVoucherEnvelope(string: String)
	case unknownTypeExpectedVoucher(string: String)
	case unknownStrategy(string: String)
	case unknownLicence(string: String)
	case expectedStringListForLockParameters
	case lobValueNull
	case versionNull
	case ciphertextNull
	case cipherivNull
}

// MARK: - LocalizedError
extension DRMIonVoucherError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .dataFromStringFailed(string):
			return "Failed to get bytes from string: \(string)"
		case let .unknownLockParameter(string):
			return "Unknown lock parameter: \(string)"
		case let .expectedKeySet(found):
			return "Expected KeySet, got \(found)"
		case .unknownDecryptionError:
			return "Unknown error occurred while decrypting voucher"
		case let .unknownCipherAlgorithm(string):
			return "Unknown cipher algorithm: \(string)"
		case let .unknownKeyFormat(string):
			return "Unknown key format: \(string)"
		case .envelopeEmpty:
			return "Envelope is empty"
		case .voucherEmpty:
			return "Voucher is empty"
		case let .unknownTypeExpectedVoucherEnvelope(string):
			return "Unknown type encountered in envelope, expected VoucherEnvelope, got: \(string)"
		case let .unknownTypeExpectedVoucher(string):
			return "Unknown type, expected Voucher, got: \(string)"
		case let .unknownStrategy(string):
			return "Unknown strategy: \(string)"
		case let .unknownLicence(string):
			return "Unknown license: \(string)"
		case .expectedStringListForLockParameters:
			return "Expected string list for lock_parameters"
		case .lobValueNull:
			return "lobValue was null"
		case .versionNull:
			return "version is null"
		case .ciphertextNull:
			return "cipherText is null"
		case .cipherivNull:
			return "cipherIv is null"
		}
	}
}
