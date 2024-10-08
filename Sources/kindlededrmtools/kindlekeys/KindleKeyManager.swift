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
    func getUsername() -> Data
    func getKindleInfoFiles() -> OrderedSet<String>
    func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data>
}
#endif
