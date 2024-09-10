//
//  URL+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension URL {
    var filenameRoot: String {
        return deletingPathExtension().lastPathComponent
    }
}
