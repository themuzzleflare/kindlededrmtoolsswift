//
//  ObfuscationValue.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

struct ObfuscationValue {
	let magicNumber: Int
	let word: Data?
	
	init(magicNumber: Int, word: Data? = nil) {
		self.magicNumber = magicNumber
		self.word = word
	}
}

// MARK: - CustomStringConvertible
extension ObfuscationValue: CustomStringConvertible {
	var description: String {
		return "(magicNumber: \(magicNumber.description), word: \(word.formattedForOutput))"
	}
}

// MARK: - Convenience Initialisers
extension ObfuscationValue {
	init(_ magicNumber: Int, _ word: Data? = nil) {
		self.init(magicNumber: magicNumber, word: word)
	}
	
	init(magicNumber: Int, word: [UInt8]) {
		self.init(magicNumber: magicNumber, word: Data(word))
	}
	
	init(_ magicNumber: Int, _ word: [UInt8]) {
		self.init(magicNumber: magicNumber, word: word)
	}
	
	init(magicNumber: Int, word: UInt8...) {
		self.init(magicNumber: magicNumber, word: word)
	}
	
	init(_ magicNumber: Int, _ word: UInt8...) {
		self.init(magicNumber: magicNumber, word: word)
	}
	
	init(magicNumber: Int, word: String) {
		self.init(magicNumber: magicNumber, word: word.data(using: .ascii))
	}
	
	init(_ magicNumber: Int, _ word: String) {
		self.init(magicNumber: magicNumber, word: word)
	}
}
