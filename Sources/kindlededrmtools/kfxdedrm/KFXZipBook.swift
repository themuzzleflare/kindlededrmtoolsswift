//
//  KFXZipBook.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

public final class KFXZipBook {
    private static let version: String = "2.0"
    
    private let infile: String
    
    init(infile: String) {
        self.infile = infile
        print("KFXDeDRM v\(KFXZipBook.version).")
        print("Removes DRM protection from KFX-ZIP and KFX eBooks.")
    }
}

extension KFXZipBook: BookManager {
    public func getBookTitle() -> String {
        return ""
    }
    
    public func getBookType() -> String {
        return "KFX-ZIP"
    }
    
    public func getBookExtension() -> String {
        return ".kfx-zip"
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
