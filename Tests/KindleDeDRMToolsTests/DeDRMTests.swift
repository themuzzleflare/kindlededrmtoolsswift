//
//  DeDRMTests.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 8/10/2024.
//

import Foundation
import Testing
@testable import KindleDeDRMTools

@Suite("DeDRM Tests")
struct DeDRMTests {
    @Test("generateKeyfileThrowing Test") func testGenerateKeyfileThrowing() throws {
        Debug.enable()
        let outpath: String = "/Users/paultavitian/tempFolder/"
        try DeDRM.generateKeyfileThrowing(outpath: outpath)
    }
}
