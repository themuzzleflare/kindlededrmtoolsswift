//
//  KindleKeyWindows.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(Windows)
import Foundation
import OrderedCollections

final class KindleKeyWindows: KindleKey {
	override func getUsername() throws -> Data {
		fatalError("Not implemented")
	}
	
	override func getKindleInfoFiles() throws -> OrderedSet<String> {
		fatalError("Not implemented")
	}
	
	override func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data> {
		fatalError("Not implemented")
	}
}
#endif
