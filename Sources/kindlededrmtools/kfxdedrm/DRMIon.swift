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
        Debug.print("DRMIon.", #function, separator: "")
        
        ion = .init(ionStream)
        IonUtils.addProtTable(ion)
        self.voucher = voucher
    }
    
    convenience init(_ ionStream: DataInputStream, _ voucher: DRMIonVoucher) {
        Debug.print("DRMIon.", #function, separator: "")
        
        self.init(ionStream: ionStream, voucher: voucher)
    }
    
    func parse(outpages: DataOutputStream) throws {
        Debug.print("DRMIon.", #function, separator: "")
        
        ion.reset()
        
        if try !ion.hasNext() {
            throw DRMIonError.drmIonEnvelopeEmpty
        }
        
        if try (ion.next() != IonUtils.TID_SYMBOL || ion.getTypeName() != "doctype") {
            throw DRMIonError.expectedDoctypeSymbol(string: try ion.getTypeName())
        }
        
        if try (ion.next() != IonUtils.TID_LIST || (ion.getTypeName() != "com.amazon.drm.Envelope@1.0" &&
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
                        try processPage(ct, civ, outpages, decompress, decrypt)
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
                        try processPage(plaintext, nil, outpages, decompress, decrypt)
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
        Debug.print("DRMIon.", #function, separator: "")
        
        var msg: Data
        
        if decrypt {
            guard let key else {
                throw DRMIonError.keyNull
            }
            
            let keyRange: Data = .init(key.prefix(16))
            let civRange: Data = civ != nil ? .init(civ!.prefix(16)) : .init()
            
            msg = try CryptoUtils.aescbcdecrypt(keyRange, civRange, ct)
        } else {
            msg = ct
        }
        
        if !decompress {
            outpages.write(msg)
            return
        }
        
        if msg[0] != 0 {
            throw DRMIonError.lzmaUseFilterNotSupported
        }
        
        decompressData(msg.subdata(in: 1..<msg.count), outpages)
    }
    
    private func processPage(_ ct: Data, _ civ: Data? = nil, _ outpages: DataOutputStream, _ decompress: Bool, _ decrypt: Bool) throws {
        Debug.print("DRMIon.", #function, separator: "")
        
        try processPage(ct: ct, civ: civ, outpages: outpages, decompress: decompress, decrypt: decrypt)
    }
}

// MARK: - LZMA
extension DRMIon {
    private func decompressData(data: Data, outputStream: DataOutputStream) {
        Debug.print("DRMIon.", #function, separator: "")
        
        let algorithm: compression_algorithm = COMPRESSION_LZMA
        let dataToWrite: Data? = data.withUnsafeBytes { (srcBuffer: UnsafeRawBufferPointer) -> Data? in
            guard let srcPointer = srcBuffer.baseAddress else { return nil }
            let srcSize = data.count
            
            // Estimate the size of the decompressed data
            let dstSize = 10 * srcSize  // Adjust size accordingly
            let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
            defer { dstBuffer.deallocate() }
            
            let decompressedSize = compression_decode_buffer(
                dstBuffer, dstSize,
                srcPointer.assumingMemoryBound(to: UInt8.self), srcSize,
                nil,
                algorithm
            )
            
            guard decompressedSize != 0 else { return nil }
            return Data(bytes: dstBuffer, count: decompressedSize)
        }
        
        if let dataToWrite {
            outputStream.write(dataToWrite)
        }
    }
    
    private func decompressData(_ data: Data, _ outputStream: DataOutputStream) {
        Debug.print("DRMIon.", #function, separator: "")
        
        decompressData(data: data, outputStream: outputStream)
    }
}
