//
//  KindleKeyManager.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

protocol KindleKeyManager {
    static func getUsername() -> Data
    static func getKindleInfoFiles() -> OrderedSet<String>
}
