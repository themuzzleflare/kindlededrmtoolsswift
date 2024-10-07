//
//  KindleKeyWindows.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(Windows)
import Foundation
import OrderedCollections

final class KindleKeyWindows {
    
}

// MARK: - KindleKeyManager
extension KindleKeyWindows: KindleKeyManager {
    static func getUsername() -> Data {
        fatalError()
    }
    
    static func getKindleInfoFiles() -> OrderedSet<String> {
        fatalError()
    }
    
    static func getDbFromFile(kinfoFile: String) -> OrderedDictionary<String, Data> {
        fatalError()
    }
}
#endif
