//
//  DeDRM.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

public enum DeDRM {
    private static let version: String = "3.0"
    
    private static func cleanupName(name: String) -> String {
        // substitute filename-unfriendly characters
        var cleanedName: String = name
            .replacingOccurrences(of: "<", with: "[")
            .replacingOccurrences(of: ">", with: "]")
            .replacingOccurrences(of: " : ", with: " – ")
            .replacingOccurrences(of: ": ", with: " – ")
            .replacingOccurrences(of: ":", with: "—")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_") // replace \ with _
            .replacingOccurrences(of: "|", with: "_")
            .replacingOccurrences(of: "\"", with: "'") // replace double quote with single quote
            .replacingOccurrences(of: "*", with: "_")
            .replacingOccurrences(of: "?", with: "")
        
        // Adjacent whitespaces to a single space, trim leading and trailing whitespace
        cleanedName = cleanedName
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        // Delete control characters
        cleanedName = cleanedName.trimmingCharacters(in: .controlCharacters)
        
        // Delete non-ASCII characters
        cleanedName.removeAll(where: { !$0.isASCII })
        
        // Remove leading dots
        while cleanedName.hasPrefix(".") {
            cleanedName.removeFirst()
        }
        
        // Remove trailing dots (Windows doesn't like them)
        while cleanedName.hasSuffix(".") {
            cleanedName.removeLast()
        }
        
        // If the name is empty, assign a default value
        if cleanedName.isEmpty {
            cleanedName = "DecryptedBook"
        }
        
        return cleanedName
    }
    
    private static func unescape(text: String) -> String {
        return text
    }
    
    private static func calculateOutfileName(filename: String, booktitle: String) throws -> String {
        guard let url: URL = .init(string: filename) else {
            throw DeDRMError.urlCreationFailed(string: filename)
        }
        
        let origfnroot: String = url.filenameRoot
        
        var outfilename: String = origfnroot
        
        let regexRange1: Range<String.Index>? = origfnroot.range(of: "^B[A-Z0-9]{9}(_EBOK|_EBSP|_sample)?$", options: .regularExpression)
        let regexRange2: Range<String.Index>? = origfnroot.range(of: "^[0-9A-F-]{36}$", options: .regularExpression)
        
        if regexRange1 != nil || regexRange2 != nil {
            let cleanTitle: String = cleanupName(name: booktitle)
            outfilename = "\(origfnroot)_\(cleanTitle)"
        }
        
        // Avoid excessively long file names
        if outfilename.count > 150 {
            let prefix: String.SubSequence = outfilename.prefix(99)
            let suffix: String.SubSequence = outfilename.suffix(49)
            outfilename = "\(prefix)--\(suffix)"
        }
        
        outfilename.append("_nodrmswift")
        
        return outfilename
    }
    
    private static func loadKDatabaseRecords(kDatabaseFiles: OrderedSet<String>) -> OrderedSet<KDatabaseRecord> {
        return .init()
    }
    
    private static func decryptionRoutine(infile: String, outdir: String, kDatabaseRecords: OrderedSet<KDatabaseRecord>, serials: OrderedSet<String>, pids: OrderedSet<String>, startTime: Date = .now) throws {
        do {
            let book: BookManager = try getDecryptedBook(infile: infile, kDatabaseRecords: kDatabaseRecords, serials: serials, pids: pids)
            
            let outfilename: String = try calculateOutfileName(filename: infile, booktitle: book.getBookTitle())
            
            guard let outdirUrl: URL = .init(string: outdir) else {
                throw DeDRMError.urlCreationFailed(string: outdir)
            }
            
            let outfilenameWithExtension: String = outfilename + book.getBookExtension()
            let outpath: String = outdirUrl.appending(path: outfilenameWithExtension).path(percentEncoded: false)
            
            try book.getFile(outpath: outpath)
            
            print("Saved decrypted book \(outfilename) after \(Date.now.timeIntervalSince(startTime).oneDecimalPlace) seconds")
            
            book.cleanup()
        } catch {
            print("Error decrypting book after \(Date.now.timeIntervalSince(startTime).oneDecimalPlace) seconds: \(error.localizedDescription)")
            throw error
        }
    }
    
    private static func getDecryptedBook(infile: String, kDatabaseRecords: OrderedSet<KDatabaseRecord>, serials: OrderedSet<String>, pids: OrderedSet<String>, startTime: Date = Date.now) throws -> BookManager {
        let book: BookManager!
        
        var mobi: Bool = true
        
        let url: URL = .init(filePath: infile)
        
        let magic8: Data = try .init(contentsOf: url).prefix(8)
        let magic3: Data = magic8.prefix(3)
        let magic4: Data = magic8.prefix(4)
        
        if magic8 == CharMaps.kfxDrmIonBytes {
            throw DeDRMError.noVoucher
        }
        
        if magic3 == CharMaps.topazBytes {
            mobi = false
        }
        
        if magic4 == CharMaps.pkBytes {
            book = KFXZipBook(infile: infile)
        } else if mobi {
            book = try MobiBook(infile: infile)
        } else {
            book = TopazBook(infile: infile)
        }
        
        let bookname: String = unescape(text: book.getBookTitle())
        let booktype: String = book.getBookType()
        
        print("Decrypting \(booktype) eBook: \(bookname)")
        
        var totalPids: OrderedSet<String> = .init(pids)
        
        let pidMetaInfo: PIDMetaInfo = book.getPidMetaInfo()
        
        let rec209: Data? = pidMetaInfo.rec209
        let token: Data? = pidMetaInfo.token
        
        totalPids.append(contentsOf: KindlePID.getPidSet(rec209: rec209, token: token, serials: serials, kDatabaseRecords: kDatabaseRecords))
        
        print("Found \(totalPids.count.description) keys to try after \(Date.now.timeIntervalSince(startTime).oneDecimalPlace) seconds")
        
        do {
            try book.processBook(pidSet: totalPids)
        } catch {
            book.cleanup()
            throw error
        }
        
        print("Decryption succeeded after \(Date.now.timeIntervalSince(startTime).oneDecimalPlace) seconds")
        
        return book
    }
    
    public static func decryptBook(infile: String, outdir: String, kDatabaseFiles: OrderedSet<String>, serials: OrderedSet<String>, pids: OrderedSet<String>, startTime: Date = .now) {
        print("K4MobiDeDrm v\(DeDRM.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from Mobipocket, Amazon KF8, Amazon Print Replica, and Amazon Topaz eBooks.")
        
        let kDatabaseRecords: OrderedSet<KDatabaseRecord> = loadKDatabaseRecords(kDatabaseFiles: kDatabaseFiles)
        
        do {
            try decryptionRoutine(infile: infile, outdir: outdir, kDatabaseRecords: kDatabaseRecords, serials: serials, pids: pids, startTime: startTime)
        } catch {
        }
    }
    
    public static func decryptBookThrowing(infile: String, outdir: String, kDatabaseFiles: OrderedSet<String>, serials: OrderedSet<String>, pids: OrderedSet<String>, startTime: Date = .now) throws {
        print("K4MobiDeDrm v\(DeDRM.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from Mobipocket, Amazon KF8, Amazon Print Replica, and Amazon Topaz eBooks.")
        
        let kDatabaseRecords: OrderedSet<KDatabaseRecord> = loadKDatabaseRecords(kDatabaseFiles: kDatabaseFiles)
        
        try decryptionRoutine(infile: infile, outdir: outdir, kDatabaseRecords: kDatabaseRecords, serials: serials, pids: pids, startTime: startTime)
    }
    
    public static func decryptBooks(infiles: OrderedSet<String>, outdir: String, kDatabaseFiles: OrderedSet<String>, serials: OrderedSet<String>, pids: OrderedSet<String>, startTime: Date = .now) {
        print("K4MobiDeDrm v\(DeDRM.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from Mobipocket, Amazon KF8, Amazon Print Replica, and Amazon Topaz eBooks.")
        
        let kDatabaseRecords: OrderedSet<KDatabaseRecord> = loadKDatabaseRecords(kDatabaseFiles: kDatabaseFiles)
        
        var decryptionCounter: Int = 0
        
        for infile in infiles {
            do {
                defer { print() }
                
                try decryptionRoutine(infile: infile, outdir: outdir, kDatabaseRecords: kDatabaseRecords, serials: serials, pids: pids, startTime: startTime)
                decryptionCounter += 1
            } catch {
            }
        }
        
        print("Decryption of \(decryptionCounter.description)/\(infiles.count.description) books completed after \(Date.now.timeIntervalSince(startTime).oneDecimalPlace) seconds")
    }
}
