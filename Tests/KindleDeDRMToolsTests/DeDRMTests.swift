//
//  DeDRMTests.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 8/10/2024.
//

import Testing
@testable import KindleDeDRMTools

@Suite("DeDRM Tests")
struct DeDRMTests {
	@Test("generateKeyfileThrowing Test", arguments: [
		"/Users/paultavitian/tempFolder/",
		"/Users/paultavitian/Downloads/kindlekeytest.k4i"
	]) func testGenerateKeyfileThrowing(outpath: String) throws {
		try DeDRM.generateKeyfileThrowing(outpath: outpath)
	}
}
