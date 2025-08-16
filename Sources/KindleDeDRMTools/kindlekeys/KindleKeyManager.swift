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
    func getUsername() throws -> Data
    func getKindleInfoFiles() throws -> OrderedSet<String>
    func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data>
    
    func kindleKeys(files: OrderedSet<String>?) throws -> OrderedSet<KindleDatabase>
    func getKeyThrowing(outpath: String, files: OrderedSet<String>?) throws
    
    static func unprotectHeaderData(encryptedData: Data) throws -> Data
    static func primes(n: Int) -> [Int]
}

extension KindleKeyManager {
    func kindleKeys(files: OrderedSet<String>? = nil) throws -> OrderedSet<KindleDatabase> {
        return try kindleKeys(files: files)
    }
    
    func getKeyThrowing(outpath: String, files: OrderedSet<String>? = nil) throws {
        try getKeyThrowing(outpath: outpath, files: files)
    }
}
#endif
