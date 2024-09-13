//
//  TopazBook.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

public final class TopazBook {
    private static let version: String = "1.0"
    
    init(infile: String) {
        print("TopazExtract v\(TopazBook.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from Topaz eBooks and extracts the contents.")
    }
}

extension TopazBook: BookManager {
    public func getBookTitle() -> String {
        return ""
    }
    
    public func getBookType() -> String {
        return "Topaz"
    }
    
    public func getBookExtension() -> String {
        return ".htmlz"
    }
    
    public func getFile(outpath: String) throws {
    }
    
    public func processBook(pidSet: OrderedSet<String>) throws {
    }
    
    public func getPidMetaInfo() -> PIDMetaInfo {
        return .init(rec209: nil, token: nil)
    }
    
    public func cleanup() {
    }
}
