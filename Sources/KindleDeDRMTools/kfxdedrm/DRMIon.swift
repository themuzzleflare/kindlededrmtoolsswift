//
//  DRMIon.swift
//
//
//  Created by Paul Tavitian on 12/9/2024.
//

import Foundation
import Compression

final class DRMIon {
	private let ion: BinaryIonParser
	private let voucher: DRMIonVoucher
	private var voucherName: String = ""
	private var key: Data?
	
	init(ionStream: DataInputStream, voucher: DRMIonVoucher) {
		ion = .init(stream: ionStream)
		IonUtils.addProtTable(ion: ion)
		self.voucher = voucher
	}
	
	func parse(outpages: DataOutputStream) throws {
		ion.reset()
		
		if try !ion.hasNext() {
			throw DRMIonError.drmIonEnvelopeEmpty
		}
		
		if try (ion.next() != IonUtils.TID_SYMBOL || ion.getTypeName() != "doctype") {
			throw DRMIonError.expectedDoctypeSymbol(string: try ion.getTypeName())
		}
		
		if try ((ion.next() != IonUtils.TID_LIST) || (ion.getTypeName() != "com.amazon.drm.Envelope@1.0" &&
													  ion.getTypeName() != "com.amazon.drm.Envelope@2.0")) {
			throw DRMIonError.unknownTypeExpectedEnvelope(string: try ion.getTypeName())
		}
		
		while true {
			if try ion.getTypeName() == "enddoc" {
				break
			}
			
			try ion.stepIn()
			
			while try ion.hasNext() {
				try ion.next()
				
				if try (ion.getTypeName() == "com.amazon.drm.EnvelopeMetadata@1.0" || ion.getTypeName() == "com.amazon.drm.EnvelopeMetadata@2.0") {
					try ion.stepIn()
					
					while try ion.hasNext() {
						try ion.next()
						
						if try ion.getFieldName() != "encryption_voucher" {
							continue
						}
						
						if voucherName.isEmpty {
							voucherName = try ion.stringValue()
							key = voucher.getSecretKey()
							
							if key == nil {
								throw DRMIonError.unableToObtainSecretKeyFromVoucher
							}
						} else {
							if try ion.stringValue() != voucherName {
								throw DRMIonError.unexpectedDifferentVouchersRequiredForSameFile
							}
						}
					}
					
					try ion.stepOut()
				} else if try (ion.getTypeName() == "com.amazon.drm.EncryptedPage@1.0" || ion.getTypeName() == "com.amazon.drm.EncryptedPage@2.0") {
					var decompress: Bool = false
					let decrypt: Bool = true
					var ct: Data? = nil
					var civ: Data? = nil
					
					try ion.stepIn()
					
					while try ion.hasNext() {
						try ion.next()
						
						if try ion.getTypeName() == "com.amazon.drm.Compressed@1.0" {
							decompress = true
						}
						
						if try ion.getFieldName() == "cipher_text" {
							ct = try ion.lobValue()
						} else if try ion.getFieldName() == "cipher_iv" {
							civ = try ion.lobValue()
						}
					}
					
					if let ct, let civ {
						try processPage(
							ct: ct,
							civ: civ,
							outpages: outpages,
							decompress: decompress,
							decrypt: decrypt
						)
					}
					
					try ion.stepOut()
				} else if try (ion.getTypeName() == "com.amazon.drm.PlainText@1.0" || ion.getTypeName() == "com.amazon.drm.PlainText@2.0") {
					var decompress: Bool = false
					let decrypt: Bool = false
					var plaintext: Data? = nil
					
					try ion.stepIn()
					
					while try ion.hasNext() {
						try ion.next()
						
						if try ion.getTypeName() == "com.amazon.drm.Compressed@1.0" {
							decompress = true
						}
						
						if try ion.getFieldName() == "data" {
							plaintext = try ion.lobValue()
						}
					}
					
					if let plaintext {
						try processPage(
							ct: plaintext,
							civ: nil,
							outpages: outpages,
							decompress: decompress,
							decrypt: decrypt
						)
					}
					
					try ion.stepOut()
				}
			}
			
			try ion.stepOut()
			
			if try !ion.hasNext() {
				break
			}
			
			try ion.next()
		}
	}
	
	private func processPage(ct: Data, civ: Data? = nil, outpages: DataOutputStream, decompress: Bool, decrypt: Bool) throws {
		var msg: Data
		
		if decrypt {
			guard let key else {
				throw DRMIonError.keyNull
			}
			
			let keyRange: Data = .init(key.prefix(16))
			let civRange: Data = civ != nil ? .init(civ!.prefix(16)) : .init()
			
			msg = try CryptoUtils
				.aescbcdecrypt(key: keyRange, iv: civRange, cipherText: ct)
		} else {
			msg = ct
		}
		
		if !decompress {
			outpages.write(data: msg)
			return
		}
		
		if msg[0] != 0 {
			throw DRMIonError.lzmaUseFilterNotSupported
		}
		
		decompressData(data: msg.subdata(in: 1..<msg.count), outputStream: outpages)
	}
}

// MARK: - LZMA
extension DRMIon {
	private func decompressData(data: Data, outputStream: DataOutputStream) {
		let dataToWrite: Data? = decompressLZMA(data: data)
		
		if let dataToWrite {
			outputStream.write(dataToWrite)
		}
	}
	
	private func decompressLZMA(data: Data) -> Data? {
		// Create a buffer to hold the decompressed data
		let bufferSize: Int = 64 * 1024
		
		var outputData: Data = .init()
		
		// Initialise the compression stream
		var stream: compression_stream = UnsafeMutablePointer.allocate(capacity: 1).pointee
		
		defer {
			compression_stream_destroy(&stream)
		}
		
		var status: compression_status = compression_stream_init(
			&stream,
			COMPRESSION_STREAM_DECODE,
			COMPRESSION_LZMA
		)
		
		guard status != COMPRESSION_STATUS_ERROR else {
			return nil
		}
		
		// Set the source data
		data.withUnsafeBytes { inputPtr in
			guard let baseAddress: UnsafeRawPointer = inputPtr.baseAddress else {
				return
			}
			
			stream.src_ptr = baseAddress.assumingMemoryBound(to: UInt8.self)
			stream.src_size = data.count
		}
		
		// Allocate destination buffer
		let dstBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: bufferSize)
		
		defer {
			dstBuffer.deallocate()
		}
		
		// Perform decompression
		repeat {
			stream.dst_ptr = dstBuffer
			stream.dst_size = bufferSize
			
			status = compression_stream_process(&stream, 0)
			
			if status == COMPRESSION_STATUS_ERROR {
				return nil
			}
			
			let outputSize: Int = bufferSize - stream.dst_size
			
			outputData.append(dstBuffer, count: outputSize)
		} while status == COMPRESSION_STATUS_OK
		
		return outputData
	}
}

// MARK: - Convenience Initialisers/Methods
extension DRMIon {
	convenience init(_ ionStream: DataInputStream, _ voucher: DRMIonVoucher) {
		self.init(ionStream: ionStream, voucher: voucher)
	}
	
	convenience init(ion: Data, voucher: DRMIonVoucher) {
		let stream: DataInputStream = .init(data: ion)
		self.init(ionStream: stream, voucher: voucher)
	}
	
	convenience init(_ ion: Data, _ voucher: DRMIonVoucher) {
		self.init(ion: ion, voucher: voucher)
	}
	
	func parse(_ outpages: DataOutputStream) throws {
		try parse(outpages: outpages)
	}
	
	private func processPage(_ ct: Data, _ civ: Data? = nil, _ outpages: DataOutputStream, _ decompress: Bool, _ decrypt: Bool) throws {
		try processPage(ct: ct, civ: civ, outpages: outpages, decompress: decompress, decrypt: decrypt)
	}
	
	private func decompressData(_ data: Data, _ outputStream: DataOutputStream) {
		decompressData(data: data, outputStream: outputStream)
	}
}
