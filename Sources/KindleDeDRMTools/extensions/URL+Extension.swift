//
//  URL+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension URL {
	static var inputTemporaryDirectory: URL {
		return Util.appending(base: Util.temporaryDirectory(), add: "input", isDirectory: true)
	}
	
	static var outputTemporaryDirectory: URL {
		return Util.appending(base: Util.temporaryDirectory(), add: "output", isDirectory: true)
	}
	
	var filename: String {
		return lastPathComponent
	}
	
	var filenameRoot: String {
		return deletingPathExtension().lastPathComponent
	}
}
