//
//  KDatabaseRecord.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation

struct KDatabaseRecord: Hashable {
    let dbFile: String
    let kindleDatabase: KindleDatabase
    
    init(dbFile: String, kindleDatabase: KindleDatabase) {
        self.dbFile = dbFile
        self.kindleDatabase = kindleDatabase
    }
}

// MARK: - Convenience Initialisers
extension KDatabaseRecord {
    init(_ dbFile: String, _ kindleDatabase: KindleDatabase) {
        self.init(dbFile: dbFile, kindleDatabase: kindleDatabase)
    }
}
