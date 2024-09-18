//
//  URL+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension URL {
    static var inputTemporaryDirectory: URL {
        return Util
            .url(
                filePath: "input",
                isDirectory: true,
                relativeTo: Util.temporaryDirectory()
            )
    }
    
    static var outputTemporaryDirectory: URL {
        return Util
            .url(
                filePath: "output",
                isDirectory: true,
                relativeTo: Util.temporaryDirectory()
            )
    }
    
    var filename: String {
        return lastPathComponent
    }
    
    var filenameRoot: String {
        return deletingPathExtension().lastPathComponent
    }
}
