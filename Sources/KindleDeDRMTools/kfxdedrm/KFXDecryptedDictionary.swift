//
//  KFXDecryptedDictionary.swift
//
//
//  Created by Paul Tavitian on 13/9/2024.
//

import Foundation

#if canImport(OrderedCollections)
import OrderedCollections
typealias KFXDecryptedDictionary = OrderedDictionary<String, Data>
#else
typealias KFXDecryptedDictionary = [String: Data]
#endif
