//
//  URL+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension URL {
    static var inputTemporaryDirectory: URL {
        return .temporaryDirectory.appending(path: "input", directoryHint: .isDirectory)
    }
    
    static var outputTemporaryDirectory: URL {
        return .temporaryDirectory.appending(path: "output", directoryHint: .isDirectory)
    }
    
    var filename: String {
        return lastPathComponent
    }
    
    var filenameRoot: String {
        return deletingPathExtension().lastPathComponent
    }
}
