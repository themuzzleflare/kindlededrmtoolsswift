//
//  BookManager.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation
import Collections

protocol BookManager: BookCleanup {
    func getBookTitle() -> String
    func getBookType() -> String
    func getBookExtension() -> String
    func getFile(outpath: String) throws
    func processBook(pidSet: OrderedSet<String>) throws
    func getPidMetaInfo() -> PIDMetaInfo
}
