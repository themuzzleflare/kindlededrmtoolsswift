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
        var voucherFilename: String!
        var voucherData: Data!
        var decrypted: Bool = false
        var decryptedVoucher: DRMIonVoucher!
        
        let url: URL = .init(filePath: infile)
        let archive: Archive = try .init(url: url, accessMode: .read)
        
        var foundVoucher: Bool = false
        
        for entry in archive {
            var data: Data = .init()
            
            _ = try archive.extract(entry) { entryData in
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
        
    outerLoop: for pid in pidSet + [""] {
        for (dsnLen, secretLen) in [(0, 0), (16, 0), (16, 40), (32, 0), (32, 40), (40, 0), (40, 40)] {
            if pid.count == dsnLen + secretLen {
                // Split the PID into DSN and account secret
                let dsnSubstr: String.SubSequence = pid.prefix(dsnLen)
                let accountSecretSubstr: String.SubSequence = pid.suffix(secretLen)
                
                let dsn: String = .init(dsnSubstr)
                let accountSecret: String = .init(accountSecretSubstr)
                
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
        defer {
            do {
                try FileManager.default.removeItem(at: .outputTemporaryDirectory)
                Debug.print("Removed directory:", URL.outputTemporaryDirectory.path(percentEncoded: false))
            } catch {
                Debug.print("Failed to remove directory:", URL.outputTemporaryDirectory.path(percentEncoded: false))
            }
        }
        
        let infileUrl: URL = .init(filePath: infile)
        let outpathUrl: URL = .init(filePath: outpath)
        
        guard !decrypted.isEmpty else {
            let infileData: Data = try .init(contentsOf: infileUrl)
            try infileData.write(to: outpathUrl)
            return
        }
        
        let infileArchive: Archive = try .init(url: infileUrl, accessMode: .read)
        let outfileArchive: Archive = try .init(accessMode: .create)
        
        try FileManager.default.createDirectory(at: .outputTemporaryDirectory, withIntermediateDirectories: true)
        
        Debug.print("Created directory:", URL.outputTemporaryDirectory.path(percentEncoded: false))
        
        for infileEntry in infileArchive {
            Debug.print("infileEntry:", infileEntry.path)
            
            if infileEntry.type == .directory {
                Debug.print("This entry is a directory.")
                
                let url: URL = .init(filePath: infileEntry.path, relativeTo: .outputTemporaryDirectory)
                
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                
                Debug.print("Created directory:", url.path(percentEncoded: false))
                
                continue
            }
            
            if let decryptedContent = decrypted[infileEntry.path] {
                let url: URL = .init(filePath: infileEntry.path, relativeTo: .outputTemporaryDirectory)
                
                try decryptedContent.write(to: url)
                
                try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
            } else {
                let url: URL = .init(filePath: infileEntry.path, relativeTo: .outputTemporaryDirectory)
                
                _ = try infileArchive.extract(infileEntry, to: url)
                
                try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
            }
        }
        
        try outfileArchive.data?.write(to: outpathUrl)
        
        Debug.print("Wrote data to URL:", outpathUrl.path(percentEncoded: false))
    }
    
    public func processBook(pidSet: OrderedSet<String>) throws {
        let url: URL = .init(filePath: infile)
        let archive: Archive = try .init(url: url, accessMode: .read)
        
        for entry in archive {
            var data: Data = .init()
            
            _ = try archive.extract(entry) { entryData in
                data += entryData
            }
            
            if data.prefix(8) != CharMaps.kfxDrmIonBytes {
                continue
            }
            
            if voucher == nil {
                try decryptVoucher(pidSet: pidSet)
            }
            
            print("Decrypting KFX DRMION:", entry.path)
            
            let outfile: DataOutputStream = .init()
            
            try DRMIon(.init(data.subdata(in: 8..<data.count - 8)), voucher).parse(outpages: outfile)
            
            decrypted[entry.path] = outfile.toData()
        }
        
        if decrypted.isEmpty {
            print("The .kfx-zip archive does not contain an encrypted DRMION file")
        }
    }
    
    public func getPidMetaInfo() -> PIDMetaInfo {
        return .init()
    }
    
    public func cleanup() {
    }
}
