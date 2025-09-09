//
//  MobiBookTests.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation
import XCTest
@testable import KindleDeDRMTools

final class MobiBookTests: XCTestCase {
    func testGetPidMetaInfo() throws {
        XCTAssertNotNil(Bundle.module.path(forResource: "1", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "2", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "3", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "4", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "5", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        
        let book1: String = Bundle.module.path(forResource: "1", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book2: String = Bundle.module.path(forResource: "2", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book3: String = Bundle.module.path(forResource: "3", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book4: String = Bundle.module.path(forResource: "4", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book5: String = Bundle.module.path(forResource: "5", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        
        let mobiBook1: MobiBook = try .init(infile: book1)
        let mobiBook2: MobiBook = try .init(infile: book2)
        let mobiBook3: MobiBook = try .init(infile: book3)
        let mobiBook4: MobiBook = try .init(infile: book4)
        let mobiBook5: MobiBook = try .init(infile: book5)
        
        let token1 = mobiBook1.getPidMetaInfo().token
        let token2 = mobiBook2.getPidMetaInfo().token
        let token3 = mobiBook3.getPidMetaInfo().token
        let token4 = mobiBook4.getPidMetaInfo().token
        let token5 = mobiBook5.getPidMetaInfo().token
        
        let expectedToken1: Data = .init([97, 116, 118, 58, 107, 105, 110, 58, 50, 58, 87, 98, 86, 80, 116, 54, 109, 69, 69, 68, 109, 69, 55, 115, 80, 98, 117, 98, 107, 83, 87, 48, 105, 112, 107, 82, 82, 52, 47, 72, 66, 114, 85, 68, 82, 121, 75, 115, 75, 47, 112, 76, 114, 76, 112, 86, 79, 118, 108, 55, 65, 108, 72, 90, 122, 110, 85, 83, 43, 81, 71, 43, 117, 121, 69, 68, 76, 48, 47, 82, 111, 117, 100, 106, 107, 81, 86, 72, 66, 119, 75, 120, 98, 71, 114, 78, 78, 66, 51, 100, 101, 122, 116, 78, 110, 52, 74, 83, 86, 110, 52, 106, 66, 99, 90, 98, 70, 101, 51, 83, 66, 54, 102, 69, 103, 88, 76, 116, 117, 69, 105, 114, 98, 50, 79, 80, 74, 77, 56, 57, 105, 75, 113, 66, 67, 107, 85, 72, 99, 73, 69, 77, 69, 115, 115, 108, 105, 106, 81, 79, 79, 115, 90, 87, 55, 98, 83, 102, 77, 65, 47, 118, 47, 117, 72, 109, 80, 88, 110, 89, 52, 61, 58, 86, 83, 57, 77, 101, 97, 82, 43, 74, 49, 83, 67, 48, 88, 107, 79, 87, 82, 53, 69, 113, 47, 105, 104, 121, 117, 119, 61, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        let expectedToken2: Data = .init([97, 116, 118, 58, 107, 105, 110, 58, 50, 58, 104, 107, 109, 110, 68, 80, 121, 117, 70, 81, 51, 54, 119, 97, 109, 51, 54, 65, 72, 115, 107, 76, 102, 89, 115, 117, 50, 50, 72, 112, 43, 110, 106, 80, 116, 50, 75, 117, 68, 87, 106, 104, 72, 76, 112, 86, 79, 118, 108, 55, 65, 108, 72, 90, 122, 110, 85, 83, 43, 81, 71, 43, 117, 121, 69, 68, 76, 48, 47, 82, 111, 117, 100, 106, 107, 81, 86, 72, 66, 119, 75, 120, 98, 71, 114, 78, 78, 66, 51, 100, 101, 122, 116, 78, 110, 52, 74, 83, 86, 110, 52, 106, 66, 99, 90, 98, 70, 101, 51, 83, 66, 54, 102, 69, 103, 88, 76, 116, 117, 69, 105, 114, 98, 50, 79, 80, 74, 77, 56, 57, 105, 75, 113, 66, 67, 107, 85, 72, 99, 73, 69, 77, 69, 115, 115, 108, 105, 106, 81, 79, 79, 115, 90, 87, 55, 98, 83, 102, 77, 65, 47, 118, 47, 117, 72, 109, 80, 88, 110, 89, 52, 61, 58, 80, 107, 99, 71, 109, 116, 78, 72, 47, 57, 83, 68, 112, 70, 113, 117, 121, 71, 113, 102, 108, 54, 76, 77, 54, 97, 73, 61, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        let expectedToken3: Data = .init([97, 116, 118, 58, 107, 105, 110, 58, 50, 58, 105, 73, 88, 101, 66, 54, 77, 113, 88, 122, 80, 77, 90, 118, 90, 57, 48, 83, 108, 113, 121, 83, 57, 51, 83, 100, 77, 86, 113, 113, 76, 88, 100, 102, 81, 75, 98, 66, 120, 70, 105, 108, 84, 76, 112, 86, 79, 118, 108, 55, 65, 108, 72, 90, 122, 110, 85, 83, 43, 81, 71, 43, 117, 121, 69, 68, 76, 48, 47, 82, 111, 117, 100, 106, 107, 81, 86, 72, 66, 119, 75, 120, 98, 71, 114, 78, 78, 66, 51, 100, 101, 122, 116, 78, 110, 52, 74, 83, 86, 110, 52, 106, 66, 99, 90, 98, 70, 101, 51, 83, 66, 54, 102, 69, 103, 88, 76, 116, 117, 69, 105, 114, 98, 50, 79, 80, 74, 77, 56, 57, 105, 75, 113, 66, 67, 107, 85, 72, 99, 73, 69, 77, 69, 115, 115, 108, 105, 106, 81, 79, 79, 115, 90, 87, 55, 98, 83, 102, 77, 65, 47, 118, 47, 117, 72, 109, 80, 88, 110, 89, 52, 61, 58, 116, 79, 105, 87, 116, 55, 122, 116, 77, 108, 89, 99, 43, 104, 85, 97, 116, 43, 119, 66, 85, 76, 114, 49, 49, 76, 89, 61, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        let expectedToken4: Data = .init([97, 116, 118, 58, 107, 105, 110, 58, 50, 58, 117, 72, 78, 79, 76, 88, 76, 81, 115, 52, 74, 115, 121, 108, 103, 84, 116, 106, 77, 97, 102, 74, 105, 100, 98, 56, 67, 49, 70, 54, 84, 70, 75, 51, 82, 73, 110, 101, 56, 111, 113, 80, 114, 76, 112, 86, 79, 118, 108, 55, 65, 108, 72, 90, 122, 110, 85, 83, 43, 81, 71, 43, 117, 121, 69, 68, 76, 48, 47, 82, 111, 117, 100, 106, 107, 81, 86, 72, 66, 119, 75, 120, 98, 71, 114, 78, 78, 66, 51, 100, 101, 122, 116, 78, 110, 52, 74, 83, 86, 110, 52, 106, 66, 99, 90, 98, 70, 101, 51, 83, 66, 54, 102, 69, 103, 88, 76, 116, 117, 69, 105, 114, 98, 50, 79, 80, 74, 77, 56, 57, 105, 75, 113, 66, 67, 107, 85, 72, 99, 73, 69, 77, 69, 115, 115, 108, 105, 106, 81, 79, 79, 115, 90, 87, 55, 98, 83, 102, 77, 65, 47, 118, 47, 117, 72, 109, 80, 88, 110, 89, 52, 61, 58, 68, 88, 48, 101, 57, 102, 77, 54, 117, 83, 73, 83, 71, 67, 118, 118, 86, 54, 56, 104, 103, 109, 108, 67, 88, 67, 119, 61, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        let expectedToken5: Data = .init([97, 116, 118, 58, 107, 105, 110, 58, 50, 58, 77, 111, 97, 103, 43, 101, 56, 70, 84, 80, 81, 70, 121, 51, 115, 68, 118, 69, 57, 74, 84, 50, 52, 47, 68, 48, 55, 90, 101, 53, 103, 120, 110, 82, 118, 82, 109, 87, 84, 52, 69, 101, 47, 76, 112, 86, 79, 118, 108, 55, 65, 108, 72, 90, 122, 110, 85, 83, 43, 81, 71, 43, 117, 121, 69, 68, 76, 48, 47, 82, 111, 117, 100, 106, 107, 81, 86, 72, 66, 119, 75, 120, 98, 71, 114, 78, 78, 66, 51, 100, 101, 122, 116, 78, 110, 52, 74, 83, 86, 110, 52, 106, 66, 99, 90, 98, 70, 101, 51, 83, 66, 54, 102, 69, 103, 88, 76, 116, 117, 69, 105, 114, 98, 50, 79, 80, 74, 77, 56, 57, 105, 75, 113, 66, 67, 107, 85, 72, 99, 73, 69, 77, 69, 115, 115, 108, 105, 106, 81, 79, 79, 115, 90, 87, 55, 98, 83, 102, 77, 65, 47, 118, 47, 117, 72, 109, 80, 88, 110, 89, 52, 61, 58, 98, 84, 83, 79, 70, 101, 67, 101, 53, 112, 115, 109, 66, 47, 48, 71, 80, 68, 71, 84, 118, 97, 115, 122, 116, 89, 115, 61, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        XCTAssertEqual(expectedToken1, token1)
        XCTAssertEqual(expectedToken2, token2)
        XCTAssertEqual(expectedToken3, token3)
        XCTAssertEqual(expectedToken4, token4)
        XCTAssertEqual(expectedToken5, token5)
    }
    
    func testProcessBook() throws {
        XCTAssertNotNil(Bundle.module.url(forResource: "1", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm"))
        XCTAssertNotNil(Bundle.module.url(forResource: "2", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm"))
        XCTAssertNotNil(Bundle.module.url(forResource: "3", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm"))
        XCTAssertNotNil(Bundle.module.url(forResource: "4", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm"))
        XCTAssertNotNil(Bundle.module.url(forResource: "5", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm"))
        
        let nodrmbook1url: URL = Bundle.module.url(forResource: "1", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm")!
        let nodrmbook2url: URL = Bundle.module.url(forResource: "2", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm")!
        let nodrmbook3url: URL = Bundle.module.url(forResource: "3", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm")!
        let nodrmbook4url: URL = Bundle.module.url(forResource: "4", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm")!
        let nodrmbook5url: URL = Bundle.module.url(forResource: "5", withExtension: "azw3", subdirectory: "testdata/einkbookfilesnodrm")!
        
        XCTAssertNotNil(Bundle.module.path(forResource: "1", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "2", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "3", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "4", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        XCTAssertNotNil(Bundle.module.path(forResource: "5", ofType: "azw3", inDirectory: "testdata/einkbookfiles"))
        
        let book1: String = Bundle.module.path(forResource: "1", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book2: String = Bundle.module.path(forResource: "2", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book3: String = Bundle.module.path(forResource: "3", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book4: String = Bundle.module.path(forResource: "4", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        let book5: String = Bundle.module.path(forResource: "5", ofType: "azw3", inDirectory: "testdata/einkbookfiles")!
        
        let nodrmbook1data: Data = try .init(contentsOf: nodrmbook1url)
        let nodrmbook2data: Data = try .init(contentsOf: nodrmbook2url)
        let nodrmbook3data: Data = try .init(contentsOf: nodrmbook3url)
        let nodrmbook4data: Data = try .init(contentsOf: nodrmbook4url)
        let nodrmbook5data: Data = try .init(contentsOf: nodrmbook5url)
        
        let mobiBook1: MobiBook = try .init(infile: book1)
        let mobiBook2: MobiBook = try .init(infile: book2)
        let mobiBook3: MobiBook = try .init(infile: book3)
        let mobiBook4: MobiBook = try .init(infile: book4)
        let mobiBook5: MobiBook = try .init(infile: book5)
        
        try mobiBook1.processBook(pidSet: ["vCNIml/cF7"])
        try mobiBook2.processBook(pidSet: ["JBJfi+WmJC"])
        try mobiBook3.processBook(pidSet: ["5m9pZCYOGG"])
        try mobiBook4.processBook(pidSet: ["bEQyy4RzR3"])
        try mobiBook5.processBook(pidSet: ["EGnqh3QSPS"])
        
        XCTAssertEqual(nodrmbook1data, mobiBook1.mobiData)
        XCTAssertEqual(nodrmbook2data, mobiBook2.mobiData)
        XCTAssertEqual(nodrmbook3data, mobiBook3.mobiData)
        XCTAssertEqual(nodrmbook4data, mobiBook4.mobiData)
        XCTAssertEqual(nodrmbook5data, mobiBook5.mobiData)
    }
}
