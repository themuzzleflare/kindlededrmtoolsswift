//
//  MobiBook.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation
import Collections

public final class MobiBook {
  private static let version: String = "3.0.0"
  private static let bookmobiBytes: Data = "BOOKMOBI".data(using: .ascii)!
  private static let textreadBytes: Data = "TEXtREAd".data(using: .ascii)!
  private static let exthBytes = "EXTH".data(using: .ascii)!
  
  private var dataFile: Data
  private var header: Data
  private var magic: Data
  private var numSections: Int = 0
  private var sections: BookSections = .init()
  private var metaArray: MetaDictionary = .init()
  private var sect: Data = .init()
  private var records: Int = 0
  private var compression: Int = -1
  private var mobiData: Data = .init()
  private var cryptoType: Int = -1
  private var printReplica: Bool = false
  private var extraDataFlags: Int = 0
  private var mobiLength: Int = 0
  private var mobiCodepage: Int = 1252
  private var mobiVersion: Int = -1
  
  public init(infile: String) throws {
    print("MobiDeDrm v\(MobiBook.version.description).")
    print("Removes protection from Kindle/Mobipocket, Kindle/KF8 and Kindle/Print Replica eBooks.")
    
    let url = URL(fileURLWithPath: infile)
    
    dataFile = try Data(contentsOf: url)
    
    header = dataFile[0..<78]
    
    print("header: \(Util.formatData(data: header))")
    
    magic = header[0x3C..<0x3C + 8]
    
    print("magic: \(Util.formatData(data: magic))")
    
    if magic != MobiBook.bookmobiBytes && magic != MobiBook.textreadBytes {
      throw MobiBookError.invalidFileFormat(data: magic)
    }
    
    numSections = Int(header[76..<78].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
    
    print("numSections: \(numSections.description)")
    
    for i in 0..<numSections {
      // Calculate the range for each section
      let startIndex = 78 + i * 8
      let range = startIndex..<startIndex + 8
      
      // Extract the 8-byte slice from Data
      let sectionData = dataFile.subdata(in: range)
      
      // Read values from the data slice
      let offset = Int(sectionData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
      
      let a1 = sectionData[4]
      let a2 = sectionData[5]
      let a3 = sectionData[6]
      let a4 = sectionData[7]
      
      // Calculate flags and val
      let flags = a1
      let val = Int(a2) << 16 | Int(a3) << 8 | Int(a4)
      
      // Create BookSection and add to the array
      let bookSection = BookSection(offset: offset, flags: Int(flags), val: Int(val))
      
      sections.append(bookSection)
    }
    
    print("sections: \(sections.description)")
    
    sect = loadSection(section: 0)
    
    print("sect: \(Util.formatData(data: sect))")
    
    records = Int(sect[0x8..<0x8 + 2].withUnsafeBytes { $0.load(as: UInt8.self).bigEndian })
    compression = Int(sect[0x0..<0x0 + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
    
    print("records: \(records.description)")
    print("compression: \(compression.description)")
    
    if magic == MobiBook.textreadBytes {
      print("PalmDoc format book detected.")
      return
    }
    
    mobiLength = Int(sect[0x14..<0x14 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
    mobiCodepage = Int(sect[0x1c..<0x1c + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
    mobiVersion = Int(sect[0x68..<0x68 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
    
    print("mobiLength: \(mobiLength.description)")
    print("mobiCodepage: \(mobiCodepage.description)")
    print("mobiVersion: \(mobiVersion.description)")
    
    
    if mobiLength >= 0xE4 && mobiVersion >= 5 {
      extraDataFlags = Int(sect[0xF2..<0xF2 + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
    }
    
    if compression != 17480 {
      extraDataFlags &= 0xFFFE
    }
    
    print("extraDataFlags: \(extraDataFlags.description)")
    
    let exthFlag = Int(sect[0x80..<0x80 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
    
    print("exthFlag: \(exthFlag.description)")
    
    var exth: Data = .init()
    
    if (exthFlag & 0x40) != 0 {
      let range = 16 + mobiLength..<sect.count
      exth = sect.subdata(in: range)
    }
    
    print("exth: \(Util.formatData(data: exth))")
    
    if exth.count >= 12 && exth[0..<4] == MobiBook.exthBytes {
      let nItems = Int(exth[8..<12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
      var pos = 12
      
      print("nItems: \(nItems.description)")
      
      for _ in 0..<nItems {
        let typeRange = pos..<pos + 4
        let sizeRange = pos + 4..<pos + 8
        
        let type = Int(exth.subdata(in: typeRange).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        let size = Int(exth.subdata(in: sizeRange).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        
        print("type: \(type.description)")
        print("size: \(size.description)")
        
        let contentRange = pos + 8..<pos + size
        
        let content = exth.subdata(in: contentRange)
        
        print("content: \(Util.formatData(data: content))")
        
        metaArray.updateValue(content, forKey: type)
        
        if type == 401 && size == 9 {
          let newContent: Data = .init(repeating: 100, count: 1)
          patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8);
        } else if type == 404 && size == 9 {
          let newContent: Data = .init(count: 0)
          patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8);
        } else if type == 405 && size == 9 {
          let newContent: Data = .init(count: 0)
          patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8);
        } else if type == 406 && size == 16 {
          let newContent: Data = .init(count: 8)
          patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8);
        } else if type == 208 {
          let newContent: Data = .init(count: size - 8)
          patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8);
        }
        
        pos += size
      }
    }
    
    print("metaArray: \(metaArray.description)")
  }
  
  private func loadSection(section: Int) -> Data {
    let endoff = section + 1 == numSections ? dataFile.count : sections[section + 1].offset
    let off = sections[section].offset
    return dataFile.subdata(in: off..<endoff)
  }
  
  private static func getSizeOfTrailingDataEntries(ptr: Data, size: Int, flags: Int) -> Int {
    var num = 0
    var testflags = flags >> 1
    
    while testflags != 0 {
      if (testflags & 1) != 0 {
        num += getSizeOfTrailingDataEntry(ptr: ptr, size: size - num)
      }
      
      testflags >>= 1
    }
    
    // Check the low bit to see if there's multibyte data present.
    // If multibyte data is included in the encrypted data, we'll have already cleared this flag.
    if (flags & 1) != 0 {
      num += Int((ptr[size - num - 1] & 0x3) + 1)
    }
    
    return num
  }
  
  private static func getSizeOfTrailingDataEntry(ptr: Data, size: Int) -> Int {
    var bitpos = 0
    var result = 0
    var size = size
    
    if size <= 0 { return result }
    
    while true {
      let v = ptr[size - 1]
      result |= Int(v & 0x7F) << bitpos
      
      bitpos += 7
      size -= 1
      
      if (v & 0x80) != 0 || (bitpos >= 28) || (size == 0) {
        return result
      }
    }
  }
  
  private func patch(off: Int, newContent: Data) {
    dataFile.replaceSubrange(off..<(off + newContent.count), with: newContent)
  }
  
  private func patchSection(section: Int, newContent: Data, inOff: Int = 0) {
    let endoff = (section + 1 == numSections) ? dataFile.count : sections[section + 1].offset
    let off = sections[section].offset
    
    assert(off + inOff + newContent.count <= endoff)
    
    patch(off: off + inOff, newContent: newContent)
  }
  
  private static func parseDrm(data: Data, count: Int, pidSet: OrderedSet<String>) throws -> DRMInfo {
    var foundKey: Data?
    var foundPid: String?
    
    let keyvec1: Data = .init([0x72, 0x38, 0x33, 0xB0, 0xB4, 0xF2, 0xE3, 0xCA, 0xDF, 0x09, 0x01, 0xD6, 0xE2, 0xE0, 0x3F, 0x96])
    
    for pid in pidSet {
      guard let bigPidBytes: Data = pid.data(using: .utf8) else {
        continue
      }
      
      let bigPid: Data = Util.ljustBytes(data: bigPidBytes, width: 16, padByte: 0)
      let tempKey: Data = try PukallCipher.pc1(key: keyvec1, src: bigPid, decryption: false)
      let tempKeySum: Int = Util.sumBytes(data: tempKey)
      
      for i in 0..<count {
        let startIndex = i * 0x30
        let range = startIndex..<startIndex + 0x30
        
        let buffer = data.subdata(in: range)
        
        let verification = Int(buffer.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        let size = Int(buffer.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self).bigEndian })
        let type = Int(buffer.withUnsafeBytes { $0.load(fromByteOffset: 8, as: UInt32.self).bigEndian })
        let cksum = buffer[12]
        var cookie: Data = buffer.subdata(in: 16..<16 + 32)
        
        print("verification: \(verification.description)")
        print("size: \(size.description)")
        print("type: \(type.description)")
        print("cksum: \(cksum.description)")
        print("cookie: \(Util.formatData(data: cookie))")
        
        if cksum == tempKeySum {
          cookie = try PukallCipher.pc1(key: tempKey, src: cookie)
          
          let ver = Int(cookie.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
          let flags = Int(cookie.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self).bigEndian })
          
          let finalKey: Data = cookie.subdata(in: 8..<8 + 16)
          
          let expiry1 = Int(cookie.withUnsafeBytes { $0.load(fromByteOffset: 24, as: UInt32.self).bigEndian })
          let expiry2 = Int(cookie.withUnsafeBytes { $0.load(fromByteOffset: 28, as: UInt32.self).bigEndian })
          
          print("cookie: \(Util.formatData(data: cookie))")
          print("ver: \(ver.description)")
          print("flags: \(flags.description)")
          print("finalKey: \(Util.formatData(data: finalKey))")
          print("expiry1: \(expiry1.description)")
          print("expiry2: \(expiry2.description)")
          
          if verification == ver && (flags & 0x1F) == 1 {
            foundKey = finalKey
            foundPid = pid
            break
          }
        }
      }
      
      if foundKey != nil {
        break
      }
    }
    
    return DRMInfo(key: foundKey!, pid: foundPid!)
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
