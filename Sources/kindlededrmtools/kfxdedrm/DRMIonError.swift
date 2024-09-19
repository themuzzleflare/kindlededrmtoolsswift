//
//  DRMIonError.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

enum DRMIonError {
    case drmIonEnvelopeEmpty
    case expectedDoctypeSymbol(string: String)
    case unknownTypeExpectedEnvelope(string: String)
    case unableToObtainSecretKeyFromVoucher
    case unexpectedDifferentVouchersRequiredForSameFile
    case lzmaUseFilterNotSupported
    case keyNull
}

// MARK: - LocalizedError
extension DRMIonError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .drmIonEnvelopeEmpty:
            return "DRMION envelope is empty"
        case let .expectedDoctypeSymbol(string):
            return "Expected doctype symbol, got: \(string)"
        case let .unknownTypeExpectedEnvelope(string):
            return "Unknown type encountered in DRMION envelope, expected Envelope, got \(string)"
        case .unableToObtainSecretKeyFromVoucher:
            return "Unable to obtain secret key from voucher"
        case .unexpectedDifferentVouchersRequiredForSameFile:
            return "Unexpected: Different vouchers required for same file?"
        case .lzmaUseFilterNotSupported:
            return "LZMA UseFilter not supported"
        case .keyNull:
            return "key is null"
        }
    }
}
