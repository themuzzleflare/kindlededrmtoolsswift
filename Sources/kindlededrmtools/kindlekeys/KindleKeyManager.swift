//
//  KindleKeyManager.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

public protocol KindleKeyManager {
    func getUsername() -> Data
    func getKindleInfoFiles() -> OrderedSet<String>
}
