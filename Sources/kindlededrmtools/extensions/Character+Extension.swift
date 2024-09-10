//
//  Character+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension Character {
    var codePoint: UInt32 {
        let scalars: UnicodeScalarView = unicodeScalars
        return scalars[scalars.startIndex].value
    }
}
