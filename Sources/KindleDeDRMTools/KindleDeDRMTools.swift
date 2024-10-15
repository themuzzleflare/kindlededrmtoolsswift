//
//  KindleDeDRMTools.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

import Foundation

#if swift(>=6.0)
nonisolated(unsafe) public var usePlatformChecks: Bool = true
nonisolated(unsafe) public var preferCryptoSwift: Bool = false
#else
public var usePlatformChecks: Bool = true
public var preferCryptoSwift: Bool = false
#endif
