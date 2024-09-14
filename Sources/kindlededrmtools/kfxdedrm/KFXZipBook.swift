//
//  KFXZipBook.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections
import ZIPFoundation

public final class KFXZipBook {
    private static let version: String = "2.0"
    
    private let infile: String
    private var decrypted: KFXDecryptedDictionary = .init()
    private var voucher: DRMIonVoucher!
    
    init(infile: String) {
        self.infile = infile
        print("KFXDeDRM v\(KFXZipBook.version).")
        print("\(Util.copyright).")
        print("Removes DRM protection from KFX-ZIP and KFX eBooks.")
    }
    
    private func decryptVoucher(pidSet: OrderedSet<String>) throws {
        Debug.print("KFXZipBook.", #function, separator: "")
        
        var voucherFilename: String!
        var voucherData: Data!
        var decrypted: Bool = false
        var decryptedVoucher: DRMIonVoucher!
        
        let url: URL = .init(filePath: infile)
        let archive: Archive = try .init(url: url, accessMode: .read)
        
        var foundVoucher: Bool = false
        
        for entry in archive {
            var data: Data = .init()
            
            try archive.extract(entry, skipCRC32: true) { entryData in
                data += entryData
            }
            
            if data.prefix(4) != CharMaps.voucherBytes {
                continue
            }
            
            if data.contains(CharMaps.protectedDataBytes) {
                foundVoucher = true
                voucherFilename = entry.path
                voucherData = data
                break // Found DRM voucher
            }
        }
        
        if !foundVoucher {
            throw KFXZipBookError.encryptedDrmIonFileWithoutVoucher
        }
        
        print("Decrypting KFX DRM voucher: \(voucherFilename!)")
        
        Debug.print("PIDs:", pidSet)
        
    outerLoop: for pid in pidSet {
        for lengths in [[0, 0], [16, 0], [16, 40], [32, 0], [32, 40], [40, 0], [40, 40]] {
            let dsn_len: Int = lengths[0]
            let secret_len: Int = lengths[1]
            
            if pid.count == dsn_len + secret_len {
                // Split the PID into DSN and account secret
                let startIndex: String.Index = pid.startIndex
                let endIndex: String.Index = pid.endIndex
                let dsnIndex: String.Index = pid.index(endIndex, offsetBy: -dsn_len)
                let accountSecretIndex: String.Index = pid.index(startIndex, offsetBy: dsn_len)
                let dsnSubstring: String.SubSequence = pid[..<dsnIndex]
                let accountSecretSubstring: String.SubSequence = pid[accountSecretIndex...]
                let dsn: String = .init(dsnSubstring)
                let accountSecret: String = .init(accountSecretSubstring)
                
                Debug.print("DSN:", dsn)
                Debug.print("Account Secret:", accountSecret)
                
                do {
                    let voucher: DRMIonVoucher = try .init(.init(voucherData), dsn, accountSecret)
                    try voucher.parse()
                    try voucher.decryptVoucher()
                    
                    decrypted = true
                    decryptedVoucher = voucher
                    break outerLoop // Break out of both loops if successful
                } catch {
                }
            }
        }
    }
        
        if !decrypted {
            throw KFXZipBookError.voucherDecryptionFailed
        }
        
        print("KFX DRM voucher successfully decrypted")
        
        let licenceType: String = decryptedVoucher.getLicenceType()
        
        if licenceType != "Purchase" {
            print("Warning: This book is licensed as \(licenceType). These tools are intended for use on purchased books. Continuing...")
        }
        
        voucher = decryptedVoucher
    }
}

extension KFXZipBook: BookManager {
    public func getBookTitle() -> String {
        let url: URL = .init(filePath: infile)
        return url.filenameRoot
    }
    
    public func getBookType() -> String {
        return "KFX-ZIP"
    }
    
    public func getBookExtension() -> String {
        return ".kfx-zip"
    }
    
    public func getFile(outpath: String) throws {
        Debug.print("KFXZipBook.", #function, separator: "")
        
        let infileUrl: URL = .init(filePath: infile)
        let infileData: Data = try .init(contentsOf: infileUrl)
        let outpathUrl: URL = .init(filePath: outpath)
        
        if decrypted.isEmpty {
            try infileData.write(to: outpathUrl)
        } else {
            let infileArchive: Archive = try .init(url: infileUrl, accessMode: .read)
            let outfileArchive: Archive = try .init(url: outpathUrl, accessMode: .create)
            
            for infileEntry in infileArchive {
                if infileEntry.type == .directory {
                    let url: URL = .temporaryDirectory.appending(path: infileEntry.path)
                    try FileManager().createDirectory(at: url, withIntermediateDirectories: true)
                    continue
                }
                
                if let decryptedContent = decrypted[infileEntry.path] {
                    let url: URL = .temporaryDirectory.appending(path: infileEntry.path)
                    
                    do {
                        try decryptedContent.write(to: url)
                    } catch {
                        print(error.localizedDescription)
                        throw error
                    }
                    
                    do {
                        try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
                    } catch {
                        print(error.localizedDescription)
                        throw error
                    }
                } else {
                    var data: Data = .init()
                    
                    try infileArchive.extract(infileEntry, skipCRC32: true) { entryData in
                        data += entryData
                    }
                    
                    let url: URL = .temporaryDirectory.appending(path: infileEntry.path)
                    
                    do {
                        try data.write(to: url)
                    } catch {
                        print(error.localizedDescription)
                        throw error
                    }
                    
                    do {
                        try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
                    } catch {
                        print(error.localizedDescription)
                        throw error
                    }
                }
            }
        }
    }
    
    public func processBook(pidSet: OrderedSet<String>) throws {
        Debug.print("KFXZipBook.", #function, separator: "")
        
        let url: URL = .init(filePath: infile)
        let archive: Archive = try .init(url: url, accessMode: .read)
        
        for entry in archive {
            var data: Data = .init()
            
            try archive.extract(entry, skipCRC32: true) { entryData in
                data += entryData
            }
            
            if data.prefix(8) != CharMaps.kfxDrmIonBytes {
                continue
            }
            
            if voucher == nil {
                try decryptVoucher(pidSet: pidSet)
            }
            
            print("Decrypting KFX DRMION: \(entry.path)")
            
            let outfile: DataOutputStream = .init()
            
            try DRMIon(.init(data.subdata(in: 8..<data.count - 8)), voucher).parse(outpages: outfile)
            
            decrypted[entry.path] = outfile.toData()
        }
        
        if decrypted.isEmpty {
            print("The .kfx-zip archive does not contain an encrypted DRMION file")
        }
    }
    
    public func getPidMetaInfo() -> PIDMetaInfo {
        return .init(rec209: nil, token: nil)
    }
    
    public func cleanup() {
    }
}
