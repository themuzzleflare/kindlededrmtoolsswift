//
//  KFXZipBook.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import OrderedCollections
import ZIPFoundation

final class KFXZipBook {
	private static let version: String = "3.0"
	
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
		
		let url: URL = Util.url(filePath: infile)
		
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
			
			if Util.contains(haystack: data, needle: CharMaps.protectedDataBytes) {
				foundVoucher = true
				voucherFilename = entry.path
				voucherData = data
				break // Found DRM voucher
			}
		}
		
		if !foundVoucher {
			throw KFXZipBookError.encryptedDrmIonFileWithoutVoucher
		}
		
		print("Decrypting KFX DRM voucher:", voucherFilename!)
		
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
						let voucher: DRMIonVoucher = try .init(voucherdata: voucherData, dsn: dsn, secret: accountSecret)
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

// MARK: - BookManager
extension KFXZipBook: BookManager {
	func getBookTitle() -> String {
		let url: URL = Util.url(filePath: infile)
		return url.filenameRoot
	}
	
	func getBookType() -> String {
		return "KFX-ZIP"
	}
	
	func getBookExtension() -> String {
		return ".kfx-zip"
	}
	
	func getFile(outpath: String) throws {
		defer {
			do {
				try FileManager.default.removeItem(at: .outputTemporaryDirectory)
				Debug
					.print(
						"Removed directory:",
						Util
							.urlPath(
								url: .outputTemporaryDirectory,
								percentEncoded: false
							)
					)
			} catch {
				Debug.print("Failed to remove directory:", Util
					.urlPath(
						url: .outputTemporaryDirectory,
						percentEncoded: false
					))
			}
		}
		
		let infileUrl: URL = Util.url(filePath: infile)
		let outpathUrl: URL = Util.url(filePath: outpath)
		
		guard !decrypted.isEmpty else {
			let infileData: Data = try .init(contentsOf: infileUrl)
			try infileData.write(to: outpathUrl)
			return
		}
		
		let infileArchive: Archive = try .init(url: infileUrl, accessMode: .read)
		let outfileArchive: Archive = try .init(accessMode: .create)
		
		try FileManager.default.createDirectory(at: .outputTemporaryDirectory, withIntermediateDirectories: true)
		
		Debug.print("Created directory:", Util
			.urlPath(
				url: .outputTemporaryDirectory,
				percentEncoded: false
			))
		
		for infileEntry in infileArchive {
			Debug.print("infileEntry:", infileEntry.path)
			
			let url: URL = Util.url(filePath: infileEntry.path, relativeTo: .outputTemporaryDirectory)
			
			if infileEntry.type == .directory {
				Debug.print("This entry is a directory.")
				
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
				
				Debug.print("Created directory:", Util.urlPath(url: url, percentEncoded: false))
				
				continue
			}
			
			if let decryptedContent = decrypted[infileEntry.path] {
				try decryptedContent.write(to: url)
				
				try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
			} else {
				_ = try infileArchive.extract(infileEntry, to: url)
				
				try outfileArchive.addEntry(with: infileEntry.path, fileURL: url)
			}
		}
		
		try outfileArchive.data?.write(to: outpathUrl)
		
		Debug.print("Wrote data to URL:", Util.urlPath(url: outpathUrl, percentEncoded: false))
	}
	
	func processBook(pidSet: OrderedSet<String>) throws {
		let url: URL = Util.url(filePath: infile)
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
			
			try DRMIon(
				ion: data.subdata(in: 8..<data.count - 8),
				voucher: voucher
			)
			.parse(outpages: outfile)
			
			decrypted[entry.path] = outfile.toData()
		}
		
		if decrypted.isEmpty {
			print("The .kfx-zip archive does not contain an encrypted DRMION file")
		}
	}
	
	func getPidMetaInfo() -> PIDMetaInfo {
		return .init()
	}
	
	func cleanup() {
		// no-op
	}
}

// MARK: - Convenience Initialisers/Methods
extension KFXZipBook {
	convenience init(_ infile: String) {
		self.init(infile: infile)
	}
	
	private func decryptVoucher(_ pidSet: OrderedSet<String>) throws {
		try decryptVoucher(pidSet: pidSet)
	}
}
