//
//  TopazBook.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import OrderedCollections

final class TopazBook {
    private static let version: String = "1.0"
    
    init(infile: String) {
        print("TopazExtract v\(TopazBook.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from Topaz eBooks and extracts the contents.")
    }
}

// MARK: - BookManager
extension TopazBook: BookManager {
    func getBookTitle() -> String {
        return ""
    }
    
    func getBookType() -> String {
        return "Topaz"
    }
    
    func getBookExtension() -> String {
        return ".htmlz"
    }
    
    func getFile(outpath: String) throws {
    }
    
    func processBook(pidSet: OrderedSet<String>) throws {
    }
    
    func getPidMetaInfo() -> PIDMetaInfo {
        return .init()
    }
    
    func cleanup() {
    }
}
