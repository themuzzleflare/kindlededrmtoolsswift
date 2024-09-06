//
//  File.swift
//  
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation
import Collections

final class MobiBook {
  private static let version: String = "3.0.0"
  private static let bookmobiBytes: Data = "BOOKMOBI".data(using: .ascii)!
  private static let textreadBytes: Data = "TEXtREAd".data(using: .ascii)!
  
  typealias BookSections = Array<BookSection>
  typealias MetaDictionary = OrderedDictionary<Int, Data>
  
  private var dataFile: Data
  private var header: Data
  private var magic: Data
  private let numSections: Int
  private var sections: BookSections = .init()
  private var metaArray: MetaDictionary = .init()
  private var sect: Data
  private var records: Int
  private var compression: Int
  private var mobiData: Data
  private var cryptoType: Int = -1
  private var printReplica: Bool = false
  private var extraDataFlags: Int = 0
  private var mobiLength: Int = 0
  private var mobiCodepage: Int = 1252
  private var mobiVersion: Int = -1
  
  public init(infile: String) throws {
    print("MobiDeDrm v%s.", MobiBook.version)
    print("Removes protection from Kindle/Mobipocket, Kindle/KF8 and Kindle/Print Replica eBooks.")
    
    guard let url = URL(string: infile) else {
      throw MobiBookError.urlCreationFiled
    }
    
    dataFile = try Data(contentsOf: url)
    
    header = dataFile[0...78]
    magic = header[0x3C...0x3C + 8]
    
    if header != MobiBook.bookmobiBytes && header != MobiBook.textreadBytes {
      throw MobiBookError.invalidFileFormat
    }
  }
  
  private func loadSection(section: Int) -> Data {
    let endoff = section + 1 == numSections ? dataFile.count : sections[section + 1].offset
    let off = sections[section].offset
    return dataFile[off...endoff]
  }
}

extension MobiBook: BookManager {
  func getBookTitle() -> String {
    return ""
  }
  
  func getBookType() -> String {
    if printReplica {
      return "Print Replica"
    }
    
    if mobiVersion >= 8 {
      return "Kindle Format 8"
    }
    
    if mobiVersion >= 0 {
      return "Mobipocket " + mobiVersion.description
    }
    
    return "PalmDoc"
  }
  
  func getBookExtension() -> String {
    if printReplica {
      return ".azw4"
    }
    
    if mobiVersion >= 8 {
      return ".azw3"
    }
    
    return ".mobi"
  }
  
  func getFile(outpath: String) {
  }
  
  func processBook(pidSet: OrderedSet<String>) {
  }
}
