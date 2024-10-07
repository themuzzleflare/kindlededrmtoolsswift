//
//  KindleKeyManager.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

#if os(macOS) || os(Windows)
import Foundation
import OrderedCollections

protocol KindleKeyManager {
    static func getUsername() -> Data
    static func getKindleInfoFiles() -> OrderedSet<String>
    static func getDbFromFile(kinfoFile: String) -> OrderedDictionary<String, Data>
}
#endif
