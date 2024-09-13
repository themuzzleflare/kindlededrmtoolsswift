//
//  KFXZipBookError.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

enum KFXZipBookError {
    case zipFailed
    case encryptedDrmIonFileWithoutVoucher
    case voucherDecryptionFailed
}

extension KFXZipBookError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .zipFailed:
            return "Failed to read/write zip file"
        case .encryptedDrmIonFileWithoutVoucher:
            return "The .kfx-zip archive contains an encrypted DRMION file without a DRM voucher"
        case .voucherDecryptionFailed:
            return "Failed to decrypt KFX DRM voucher with any key"
        }
    }
}
