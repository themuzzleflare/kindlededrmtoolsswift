//
//  SymbolTable.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

final class SymbolTable {
    private var table: [String]
    
    init() {
        table = .init(repeating: "", count: IonUtils.SID_ION_1_0_MAX)
        
        table[IonUtils.SID_ION] = SystemSymbols.ION
        table[IonUtils.SID_ION_1_0] = SystemSymbols.ION_1_0
        table[IonUtils.SID_ION_SYMBOL_TABLE] = SystemSymbols.ION_SYMBOL_TABLE
        table[IonUtils.SID_NAME] = SystemSymbols.NAME
        table[IonUtils.SID_VERSION] = SystemSymbols.VERSION
        table[IonUtils.SID_IMPORTS] = SystemSymbols.IMPORTS
        table[IonUtils.SID_SYMBOLS] = SystemSymbols.SYMBOLS
        table[IonUtils.SID_MAX_ID] = SystemSymbols.MAX_ID
        table[IonUtils.SID_ION_SHARED_SYMBOL_TABLE] = SystemSymbols.ION_SHARED_SYMBOL_TABLE
    }
    
    func findById(sid: Int) throws -> String {
        if sid < 1 {
            throw SymbolTableError.invalidSymbolId(id: sid)
        }
        
        if sid < table.count {
            return table[sid]
        } else {
            return ""
        }
    }
    
    func importSymbols(catalogItem: IonCatalogItem, maxId: Int) {
        for i in 0..<maxId {
            table.append(catalogItem.symnames[i])
        }
    }
    
    func importUnknown(name: String, maxId: Int) {
        for i in 0..<maxId {
            table.append("\(name)#\((i + 1).description)")
        }
    }
}

// MARK: - Convenience Initialisers/Methods
extension SymbolTable {
    func findById(_ sid: Int) throws -> String {
        return try findById(sid: sid)
    }
    
    func importSymbols(_ catalogItem: IonCatalogItem, _ maxId: Int) {
        importSymbols(catalogItem: catalogItem, maxId: maxId)
    }
    
    func importUnknown(_ name: String, _ maxId: Int) {
        importUnknown(name: name, maxId: maxId)
    }
}
