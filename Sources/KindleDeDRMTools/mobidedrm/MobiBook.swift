//
//  MobiBook.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation
import OrderedCollections

final class MobiBook {
    private static let version: String = "4.0.0"
    
    private var dataFile: Data
    private var header: Data
    private var magic: Data
    private var numSections: Int
    private var sections: BookSections = .init()
    private var metaArray: MetaDictionary = .init()
    private var sect: Data = .init()
    private var records: Int = 0
    private var compression: Int = -1
    var mobiData: Data = .init()
    private var cryptoType: Int = -1
    private var printReplica: Bool = false
    private var extraDataFlags: Int = 0
    private var mobiLength: Int = 0
    private var mobiCodepage: Int = 1252
    private var mobiVersion: Int = -1
    
    init(data: Data) throws {
        print("MobiDeDrm v\(Self.version.description).")
        print("\(Util.copyright).")
        print("Removes protection from Kindle/Mobipocket, Kindle/KF8 and Kindle/Print Replica eBooks.")
        
        dataFile = data
        
        header = dataFile.prefix(78)
        
        Debug.print("header:", header.formattedForOutput)
        
        magic = header[0x3C..<0x3C + 8]
        
        Debug.print("magic:", magic.formattedForOutput)
        
        if magic != CharMaps.bookmobiBytes && magic != CharMaps.textreadBytes {
            throw MobiBookError.invalidFileFormat(data: magic)
        }
        
        numSections = .init(header[76..<78].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
        
        Debug.print("numSections:", numSections.description)
        
        for i in 0..<numSections {
            // Calculate the range for each section
            let startIndex: Int = 78 + i * 8
            let range: Range<Int> = startIndex..<startIndex + 8
            
            // Extract the 8-byte slice from Data
            let sectionData: Data = dataFile.subdata(in: range)
            
            // Read values from the data slice
            let offset: Int = .init(sectionData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            
            let a1: UInt8 = sectionData[4]
            let a2: UInt8 = sectionData[5]
            let a3: UInt8 = sectionData[6]
            let a4: UInt8 = sectionData[7]
            
            // Calculate flags and val
            let flags: UInt8 = a1
            let val: Int = Int(a2) << 16 | Int(a3) << 8 | Int(a4)
            
            // Create BookSection and add to the array
            let bookSection: BookSection = .init(offset: offset, flags: flags, val: val)
            
            sections.append(bookSection)
        }
        
        Debug.print("sections:", sections.description)
        
        sect = loadSection(section: 0)
        
        Debug.print("sect:", sect.formattedForOutput)
        
        records = .init(sect[0x8..<0x8 + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
        compression = .init(sect[0x0..<0x0 + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
        
        Debug.print("records:", records.description)
        Debug.print("compression:", compression.description)
        
        if magic == CharMaps.textreadBytes {
            print("PalmDoc format book detected.")
            return
        }
        
        mobiLength = .init(sect[0x14..<0x14 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        mobiCodepage = .init(sect[0x1c..<0x1c + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        mobiVersion = .init(sect[0x68..<0x68 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        
        Debug.print("mobiLength:", mobiLength.description)
        Debug.print("mobiCodepage:", mobiCodepage.description)
        Debug.print("mobiVersion:", mobiVersion.description)
        
        if mobiLength >= 0xE4 && mobiVersion >= 5 {
            extraDataFlags = .init(sect[0xF2..<0xF2 + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
        }
        
        if compression != 17480 {
            extraDataFlags &= 0xFFFE
        }
        
        Debug.print("extraDataFlags:", extraDataFlags.description)
        
        let exthFlag: Int = .init(sect[0x80..<0x80 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        
        Debug.print("exthFlag:", exthFlag.description)
        
        var exth: Data = .init()
        
        if (exthFlag & 0x40) != 0 {
            let range: Range<Int> = 16 + mobiLength..<sect.count
            exth = sect.subdata(in: range)
        }
        
        Debug.print("exth:", exth.formattedForOutput)
        
        if exth.count >= 12 && exth[..<4] == CharMaps.exthBytes {
            let nItems: Int = .init(exth[8..<12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            var pos: Int = 12
            
            Debug.print("nItems:", nItems.description)
            
            for _ in 0..<nItems {
                let typeRange: Range<Int> = pos..<pos + 4
                let sizeRange: Range<Int> = pos + 4..<pos + 8
                
                let type: Int = .init(exth.subdata(in: typeRange).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                let size: Int = .init(exth.subdata(in: sizeRange).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                
                Debug.print("type:", type.description)
                Debug.print("size:", size.description)
                
                let contentRange: Range<Int> = pos + 8..<pos + size
                
                let content: Data = exth.subdata(in: contentRange)
                
                Debug.print("content:", content.formattedForOutput)
                
                metaArray[type] = content
                
                let newContent: Data?
                
                switch type {
                case 401 where size == 9:
                    newContent = .init([100])
                case 404 where size == 9, 405 where size == 9:
                    newContent = .init(count: 0)
                case 406 where size == 16:
                    newContent = .init(count: 8)
                case 208:
                    newContent = .init(count: size - 8)
                default:
                    newContent = nil
                }
                
                if let newContent {
                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                }
                
                //                if type == 401 && size == 9 {
                //                    let newContent: Data = .init([100])
                //                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                //                } else if type == 404 && size == 9 {
                //                    let newContent: Data = .init(count: 0)
                //                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                //                } else if type == 405 && size == 9 {
                //                    let newContent: Data = .init(count: 0)
                //                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                //                } else if type == 406 && size == 16 {
                //                    let newContent: Data = .init(count: 8)
                //                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                //                } else if type == 208 {
                //                    let newContent: Data = .init(count: size - 8)
                //                    patchSection(section: 0, newContent: newContent, inOff: 16 + mobiLength + pos + 8)
                //                }
                
                pos += size
            }
        }
        
        Debug.print("metaArray:", metaArray.description)
    }
    
    private func loadSection(section: Int) -> Data {
        let endoff: Int = section + 1 == numSections ? dataFile.count : sections[section + 1].offset
        let off: Int = sections[section].offset
        
        return dataFile.subdata(in: off..<endoff)
    }
    
    private static func getSizeOfTrailingDataEntries(ptr: Data, size: Int, flags: Int) -> Int {
        var num: Int = 0
        var testflags: Int = flags >> 1
        
        while testflags != 0 {
            if (testflags & 1) != 0 {
                num += getSizeOfTrailingDataEntry(ptr: ptr, size: size - num)
            }
            
            testflags >>= 1
        }
        
        // Check the low bit to see if there's multibyte data present.
        // If multibyte data is included in the encrypted data, we'll have already cleared this flag.
        if (flags & 1) != 0 {
            num += .init((ptr[size - num - 1] & 0x3) + 1)
        }
        
        return num
    }
    
    private static func getSizeOfTrailingDataEntry(ptr: Data, size: Int) -> Int {
        var bitpos: Int = 0
        var result: Int = 0
        var size: Int = size
        
        if size <= 0 {
            return result
        }
        
        while true {
            let v: UInt8 = ptr[size - 1]
            
            result |= .init(v & 0x7F) << bitpos
            bitpos += 7
            size -= 1
            
            if (v & 0x80) != 0 || bitpos >= 28 || size == 0 {
                return result
            }
        }
    }
    
    private func patch(off: Int, newContent: Data) {
        dataFile.replaceSubrange(off..<(off + newContent.count), with: newContent)
    }
    
    private func patchSection(section: Int, newContent: Data, inOff: Int = 0) {
        let endoff: Int = (section + 1 == numSections) ? dataFile.count : sections[section + 1].offset
        let off: Int = sections[section].offset
        
        assert(off + inOff + newContent.count <= endoff)
        
        patch(off: off + inOff, newContent: newContent)
    }
    
    private static func parseDrm(data: Data, count: Int, pidSet: OrderedSet<String>) throws -> DRMInfo {
        var foundKey: Data?
        var foundPid: String!
        
        let keyvec1: Data = .init([0x72, 0x38, 0x33, 0xB0, 0xB4, 0xF2, 0xE3, 0xCA, 0xDF, 0x09, 0x01, 0xD6, 0xE2, 0xE0, 0x3F, 0x96])
        
        for pid in pidSet {
            guard let bigPidBytes: Data = pid.data(using: .utf8) else { continue }
            
            let bigPid: Data = Util.ljustBytes(data: bigPidBytes, width: 16, padByte: 0)
            let tempKey: Data = try PukallCipher.pc1(key: keyvec1, src: bigPid, decryption: false)
            let tempKeySum: Int = Util.sumBytes(data: tempKey)
            
            try parseDrmRoutine(data: data,
                                count: count,
                                pid: pid,
                                tempKey: tempKey,
                                tempKeySum: tempKeySum,
                                foundKey: &foundKey,
                                foundPid: &foundPid)
            
            if foundKey != nil {
                break
            }
        }
        
        if foundKey == nil {
            foundPid = "00000000"
            
            let tempKeySum: Int = Util.sumBytes(data: keyvec1)
            
            try parseDrmRoutine(data: data,
                                count: count,
                                pid: foundPid,
                                tempKey: keyvec1,
                                tempKeySum: tempKeySum,
                                foundKey: &foundKey,
                                foundPid: &foundPid)
        }
        
        return .init(key: foundKey, pid: foundPid)
    }
    
    private static func parseDrmRoutine(data: Data,
                                        count: Int,
                                        pid: String,
                                        tempKey: Data,
                                        tempKeySum: Int,
                                        foundKey: inout Data?,
                                        foundPid: inout String?) throws {
        for i in 0..<count {
            let startIndex: Int = i * 0x30
            let range: Range<Int> = startIndex..<startIndex + 0x30
            
            let buffer: Data = data.subdata(in: range)
            
            let verification: Int = .init(buffer.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            let size: Int = .init(buffer.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self).bigEndian })
            let type: Int = .init(buffer.withUnsafeBytes { $0.load(fromByteOffset: 8, as: UInt32.self).bigEndian })
            let cksum: UInt8 = buffer[12]
            var cookie: Data = buffer.subdata(in: 16..<16 + 32)
            
            Debug.print("verification:", verification.description)
            Debug.print("size:", size.description)
            Debug.print("type:", type.description)
            Debug.print("cksum:", cksum.description)
            Debug.print("cookie:", cookie.formattedForOutput)
            
            if cksum == tempKeySum {
                cookie = try PukallCipher.pc1(key: tempKey, src: cookie)
                
                let ver: Int = .init(cookie.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                let flags: Int = .init(cookie.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self).bigEndian })
                
                let finalKey: Data = cookie.subdata(in: 8..<8 + 16)
                
                let expiry1: Int = .init(cookie.withUnsafeBytes { $0.load(fromByteOffset: 24, as: UInt32.self).bigEndian })
                let expiry2: Int = .init(cookie.withUnsafeBytes { $0.load(fromByteOffset: 28, as: UInt32.self).bigEndian })
                
                Debug.print("cookie:", cookie.formattedForOutput)
                Debug.print("ver:", ver.description)
                Debug.print("flags:", flags.description)
                Debug.print("finalKey:", finalKey.formattedForOutput)
                Debug.print("expiry1:", expiry1.description)
                Debug.print("expiry2:", expiry2.description)
                
                if verification == ver && (flags & 0x1F) == 1 {
                    foundKey = finalKey
                    foundPid = pid
                    break
                }
            }
        }
    }
    
    private static func normalisePids(pidSet: OrderedSet<String>) throws -> OrderedSet<String> {
        var goodPids: OrderedSet<String> = .init()
        
        for pid in pidSet {
            if pid.count == 10 {
                let string: String = .init(pid.prefix(pid.count - 2))
                let checksumPid: String = try KindleKeyUtils.checksumPid(data: string, charMap: CharMaps.letters)
                
                if checksumPid != pid {
                    print("Warning: PID", pid, "has an incorrect checksum, should have been", checksumPid)
                }
                
                goodPids.append(string)
            } else if pid.count == 8 {
                goodPids.append(pid)
            } else {
                print("Warning: PID", pid, "has the wrong number of digits")
            }
        }
        
        return goodPids
    }
}

// MARK: - BookManager
extension MobiBook: BookManager {
    func getBookTitle() -> String {
        let codecMap: [Int: String.Encoding] = [1252: .windowsCP1252, 65001: .utf8]
        
        var title: Data = .init()
        var codec: String.Encoding = .windowsCP1252
        
        if magic == CharMaps.bookmobiBytes {
            if let data: Data = metaArray[503] {
                title = data
            } else {
                let toff: Int = .init(sect[0x54..<0x54 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                let tlen: Int = .init(sect[0x58..<0x58 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                let tend: Int = toff + tlen
                
                title = sect.subdata(in: toff..<tend)
            }
            
            if let data: String.Encoding = codecMap[mobiCodepage] {
                codec = data
            }
        }
        
        if title.count == 0 {
            title = header.subdata(in: 0..<32).split(separator: 0)[0]
        }
        
        return .init(data: title, encoding: codec) ?? ""
    }
    
    func getBookType() -> String {
        if printReplica {
            return "Print Replica"
        } else if mobiVersion >= 8 {
            return "Kindle Format 8"
        } else if mobiVersion >= 0 {
            return "Mobipocket \(mobiVersion.description)"
        } else {
            return "PalmDoc"
        }
    }
    
    func getBookExtension() -> String {
        if printReplica {
            return ".azw4"
        } else if mobiVersion >= 8 {
            return ".azw3"
        } else {
            return ".mobi"
        }
    }
    
    func getFile(outpath: String) throws {
        let url: URL = Util.url(filePath: outpath)
        
        try mobiData.write(to: url)
    }
    
    func processBook(pidSet: OrderedSet<String>) throws {
        cryptoType = .init(sect[0xC..<0xC + 2].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
        
        print("Crypto Type is:", cryptoType.description)
        
        if cryptoType == 0 {
            print("This book is not encrypted.")
            
            let data: Data = loadSection(section: 1)
            let range: PartialRangeUpTo<Int> = ..<4
            
            printReplica = data[range] == CharMaps.mopBytes
            
            mobiData = dataFile
            
            return
        }
        
        if cryptoType != 2 && cryptoType != 1 {
            throw MobiBookError.unknownEncryptionType(type: cryptoType)
        }
        
        if let data406: Data = metaArray[406] {
            let val406: Int = .init(data406.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian })
            
            if val406 != 0 {
                print("Warning: This is a library or rented eBook (\(val406.description)). Continuing...")
            }
        }
        
        let goodPids: OrderedSet<String> = try Self.normalisePids(pidSet: pidSet)
        
        Debug.print("PIDs:", pidSet)
        Debug.print("Good PIDs:", goodPids)
        
        let foundKey: Data!
        let pid: String!
        
        if cryptoType == 1 {
            let t1Keyvec: Data = "QDCVEPMU675RUBSZ".data(using: .ascii)!
            let bookKeyData: Data!
            
            if magic == CharMaps.textreadBytes {
                bookKeyData = sect.subdata(in: 0x0E..<0x0E + 16)
            } else if mobiVersion < 0 {
                bookKeyData = sect.subdata(in: 0x90..<0x90 + 16)
            } else {
                bookKeyData = sect.subdata(in: mobiLength + 16..<mobiLength + 32)
            }
            
            pid = "00000000"
            foundKey = try PukallCipher.pc1(key: t1Keyvec, src: bookKeyData)
        } else {
            let drmPtr: Int = .init(sect[0xA8..<0xA8 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            let drmCount: Int = .init(sect[0xAC..<0xAC + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            let drmSize: Int = .init(sect[0xB0..<0xB0 + 4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            
            if drmCount == 0 {
                throw MobiBookError.encryptionNotInitialised
            }
            
            let drmData: Data = sect.subdata(in: drmPtr..<drmPtr + drmSize)
            
            let drmResult: DRMInfo = try Self.parseDrm(data: drmData, count: drmCount, pidSet: goodPids)
            
            foundKey = drmResult.key
            pid = drmResult.pid
            
            if foundKey == nil {
                throw MobiBookError.noKeyFound(pidsSize: goodPids.count)
            }
            
            patchSection(section: 0, newContent: .init(count: drmSize), inOff: drmPtr)
            patchSection(section: 0, newContent: .init(Data(repeating: 0xFF, count: 4) + Data(count: 12)), inOff: 0xA8)
        }
        
        if pid == "00000000" {
            print("File has default encryption, no specific key needed.")
        } else {
            print("File is encoded with PID \(try KindleKeyUtils.checksumPid(data: pid, charMap: CharMaps.letters)).")
        }
        
        patchSection(section: 0, newContent: .init(count: 2), inOff: 0xC)
        
        print("Decrypting. Please wait . . .", terminator: "")
        
        var decryptedData: Data = .init()
        
        let rangeToWrite: Data = dataFile.subdata(in: 0..<sections[1].offset)
        decryptedData.append(rangeToWrite)
        
        for i in 1...records {
            let data: Data = loadSection(section: i)
            let extraSize: Int = Self.getSizeOfTrailingDataEntries(ptr: data, size: data.count, flags: extraDataFlags)
            
            if i % 100 == 0 {
                print(" .", terminator: "")
            }
            
            let rangeToDecode: Data = data.subdata(in: 0..<data.count - extraSize)
            let decodedData: Data = try PukallCipher.pc1(key: foundKey, src: rangeToDecode)
            
            if i == 1 {
                printReplica = decodedData[..<4] == CharMaps.mopBytes
            }
            
            decryptedData.append(decodedData)
            
            if extraSize > 0 {
                let rangeToWrite: Data = data.subdata(in: data.count - extraSize..<data.count)
                decryptedData.append(rangeToWrite)
            }
        }
        
        if numSections > records + 1 {
            let rangeToWrite: Data = dataFile.subdata(in: sections[records + 1].offset..<dataFile.count)
            decryptedData.append(rangeToWrite)
        }
        
        mobiData = decryptedData
        
        print(" done")
    }
    
    func getPidMetaInfo() -> PIDMetaInfo {
        var rec209: Data = .init()
        var token: Data = .init()
        
        if let data: Data = metaArray[209] {
            rec209 = data
            
            for i in stride(from: 0, to: rec209.count, by: 5) {
                let startIndex: Int = i + 1
                let range: Range<Int> = startIndex..<startIndex + 4
                let val: Int = .init(rec209.subdata(in: range).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                let sval: Data = metaArray[val] ?? .init()
                token.append(sval)
            }
        }
        
        return .init(rec209: rec209, token: token)
    }
    
    func cleanup() {
        // no-op
    }
}

// MARK: - Convenience Initialisers/Methods
extension MobiBook {
    convenience init(infile: String) throws {
        let url: URL = Util.url(filePath: infile)
        try self.init(url: url)
    }
    
    convenience init(_ infile: String) throws {
        try self.init(infile: infile)
    }
    
    convenience init(url: URL) throws {
        let data: Data = try .init(contentsOf: url)
        try self.init(data: data)
    }
    
    convenience init(_ url: URL) throws {
        try self.init(url: url)
    }
    
    convenience init(_ data: Data) throws {
        try self.init(data: data)
    }
}
