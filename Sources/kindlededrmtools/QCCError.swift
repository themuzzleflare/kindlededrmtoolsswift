//
//  QCCError.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CommonCrypto

/// Wraps `CCCryptorStatus` for use in Swift.
struct QCCError: Error {
    var code: CCCryptorStatus
}

extension QCCError {
    init(code: Int) {
        self.init(code: CCCryptorStatus(code))
    }
}
