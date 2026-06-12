//
//  IonCatalogItem.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

struct IonCatalogItem {
    let name: String
    let version: Int
    let symnames: [String]

    init(name: String = "",
         version: Int = 0,
         symnames: [String] = .init()) {
        self.name = name
        self.version = version
        self.symnames = symnames
    }
}

// MARK: - Convenience Initialisers/Methods
extension IonCatalogItem {
    init(_ name: String = "", _ version: Int = 0, _ symnames: [String] = .init()) {
        self.init(name: name, version: version, symnames: symnames)
    }
}
