//
//  KindleKeyWindows.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(Windows)
import Foundation
import OrderedCollections

final class KindleKeyWindows: KindleKey {
    override class func getUsername() -> Data {
        fatalError()
    }
    
    override class func getKindleInfoFiles() -> OrderedSet<String> {
        fatalError()
    }
    
    override class func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data> {
        fatalError()
    }
}
#endif
