//
//  DRMIonVoucher.swift
//
//
//  Created by Paul Tavitian on 12/9/2024.
//

import Foundation

final class DRMIonVoucher {
    private let envelope: BinaryIonParser
    private var lockParams: [String] = .init()
    private let dsn: Data
    private let secret: Data
    private var version: Int?
    private var voucher: BinaryIonParser!
    private var drmKey: BinaryIonParser!
    private var licenceType: String = "Unknown"
    private var encAlgorithm: String = ""
    private var encTransformation: String = ""
    private var hashAlgorithm: String = ""
    private var cipherText: Data?
    private var cipherIv: Data?
    private var secretKey: Data = .init()
    
    init(voucherenv: DataInputStream, dsn: Data, secret: Data) {
        self.dsn = dsn
        self.secret = secret
        envelope = .init(voucherenv)
        
        IonUtils.addProtTable(envelope)
    }
    
    convenience init(_ voucherenv: DataInputStream, _ dsn: Data, _ secret: Data) {
        self.init(voucherenv: voucherenv, dsn: dsn, secret: secret)
    }
    
    convenience init(voucherenv: DataInputStream, dsn: String, secret: String) throws {
        guard let dsnData = dsn.data(using: .ascii) else {
            throw DRMIonVoucherError.dataFromStringFailed(string: dsn)
        }
        
        guard let secretData = secret.data(using: .ascii) else {
            throw DRMIonVoucherError.dataFromStringFailed(string: secret)
        }
        
        self.init(voucherenv: voucherenv, dsn: dsnData, secret: secretData)
    }
    
    convenience init(_ voucherenv: DataInputStream, _ dsn: String, _ secret: String) throws {
        try self.init(voucherenv: voucherenv, dsn: dsn, secret: secret)
    }
    
    func decryptVoucher() throws {
        guard let encAlgorithmBytes: Data = encAlgorithm.data(using: .ascii) else {
            throw DRMIonVoucherError.dataFromStringFailed(string: encAlgorithm)
        }
        
        guard let encTransformationBytes: Data = encTransformation.data(using: .ascii) else {
            throw DRMIonVoucherError.dataFromStringFailed(string: encTransformation)
        }
        
        guard let hashAlgorithmBytes: Data = hashAlgorithm.data(using: .ascii) else {
            throw DRMIonVoucherError.dataFromStringFailed(string: hashAlgorithm)
        }
        
        var shared: Data = CharMaps.pidv3Bytes + encAlgorithmBytes + encTransformationBytes + hashAlgorithmBytes
        
        lockParams.sort()
        
        for param in lockParams {
            if param == "ACCOUNT_SECRET" {
                guard let paramBytes = param.data(using: .ascii) else {
                    throw DRMIonVoucherError.dataFromStringFailed(string: param)
                }
                
                shared.append(paramBytes + secret)
            } else if param == "CLIENT_ID" {
                guard let paramBytes = param.data(using: .ascii) else {
                    throw DRMIonVoucherError.dataFromStringFailed(string: param)
                }
                
                shared.append(paramBytes + dsn)
                
            } else {
                throw DRMIonVoucherError.unknownLockParameter(string: param)
            }
        }
        
        guard let version else {
            throw DRMIonVoucherError.versionNull
        }
        
        let sharedSecrets: [Data] = try [IonUtils.obfuscate(shared, version),
                                         IonUtils.obfuscate2(shared, version),
                                         IonUtils.obfuscate3(shared, version),
                                         IonUtils.processV9708(shared),
                                         IonUtils.processV1031(shared),
                                         IonUtils.processV2069(shared),
                                         IonUtils.processV9041(shared),
                                         IonUtils.processV3646(shared),
                                         IonUtils.processV6052(shared),
                                         IonUtils.processV9479(shared),
                                         IonUtils.processV9888(shared),
                                         IonUtils.processV4648(shared),
                                         IonUtils.processV5683(shared)]
        
        var decrypted: Bool = false
        var ex: Error? = nil
        
        for sharedSecret in sharedSecrets {
            do {
                // Generate the key using HMAC-SHA256
                // Step 1: HMAC-SHA256 to generate the key
                let key: Data = CryptoUtils.hmacsha256(sharedSecret, CharMaps.pidv3Bytes)
                
                guard let cipherText else {
                    throw DRMIonVoucherError.ciphertextNull
                }
                
                guard let cipherIv else {
                    throw DRMIonVoucherError.cipherivNull
                }
                
                let decryptedData: Data = try CryptoUtils.aescbcdecrypt(.init(key.prefix(32)), .init(cipherIv.prefix(16)), cipherText)
                
                Debug.print("decryptedVoucher:", Util.formatData(data: decryptedData))
                
                // Parse the decrypted data as a BinaryIonParser
                drmKey = .init(.init(decryptedData))
                IonUtils.addProtTable(drmKey)
                
                // Verify that the decrypted data is a valid KeySet
                if try (!drmKey.hasNext() || drmKey.next() != IonUtils.TID_LIST || drmKey.getTypeName() != "com.amazon.drm.KeySet@1.0") {
                    throw DRMIonVoucherError.expectedKeySet(found: try drmKey.getTypeName())
                }
                
                decrypted = true
                print("Voucher decryption succeeded")
                break
            } catch {
                // Print exception for debugging and continue to the next fallback
                print("Voucher decryption failed, trying next fallback")
                ex = error
            }
        }
        
        // Step 5: Handle decryption failure
        if !decrypted {
            throw ex ?? DRMIonVoucherError.unknownDecryptionError
        }
        
        // Step 6: Parse the decrypted key data
        try drmKey.stepIn()
        
        while try drmKey.hasNext() {
            try drmKey.next()
            
            if try drmKey.getTypeName() != "com.amazon.drm.SecretKey@1.0" {
                continue
            }
            
            try drmKey.stepIn()
            
            while try drmKey.hasNext() {
                try drmKey.next()
                
                if try drmKey.getFieldName() == "algorithm" {
                    if try drmKey.stringValue() != "AES" {
                        throw DRMIonVoucherError.unknownCipherAlgorithm(string: try drmKey.stringValue())
                    }
                } else if try drmKey.getFieldName() == "format" {
                    if try drmKey.stringValue() != "RAW" {
                        throw DRMIonVoucherError.unknownKeyFormat(string: try drmKey.stringValue())
                    }
                } else if try drmKey.getFieldName() == "encoded" {
                    guard let lobValue = try drmKey.lobValue() else {
                        throw DRMIonVoucherError.lobValueNull
                    }
                    
                    secretKey = lobValue
                }
            }
            
            try drmKey.stepOut()
            break
        }
        
        try drmKey.stepOut()
    }
    
    func parse() throws {
        envelope.reset()
        
        if try !envelope.hasNext() {
            throw DRMIonVoucherError.envelopeEmpty
        }
        
        if try (envelope.next() != IonUtils.TID_STRUCT || !envelope.getTypeName().starts(with: "com.amazon.drm.VoucherEnvelope@")) {
            throw DRMIonVoucherError.unknownTypeExpectedVoucherEnvelope(string: try envelope.getTypeName())
        }
        
        let envelopeTypeNameStr: String = .init(try envelope.getTypeName().split(separator: "@")[1])
        let endIndex: String.Index = envelopeTypeNameStr.endIndex
        let index: String.Index = envelopeTypeNameStr.index(endIndex, offsetBy: -2)
        let substring: String.SubSequence = envelopeTypeNameStr[..<index]
        let string: String = .init(substring)
        version = .init(string)
        
        try envelope.stepIn()
        
        while try envelope.hasNext() {
            try envelope.next()
            
            var field: String = try envelope.getFieldName()
            
            if field == "voucher" {
                guard let lobValue = try envelope.lobValue() else {
                    throw DRMIonVoucherError.lobValueNull
                }
                
                voucher = .init(.init(lobValue))
                IonUtils.addProtTable(voucher)
                continue
            } else if field != "strategy" {
                continue
            }
            
            if try envelope.getTypeName() != "com.amazon.drm.PIDv3@1.0" {
                throw DRMIonVoucherError.unknownStrategy(string: try envelope.getTypeName())
            }
            
            try envelope.stepIn()
            
            while try envelope.hasNext() {
                try envelope.next()
                field = try envelope.getFieldName()
                
                if field == "encryption_algorithm" {
                    encAlgorithm = try envelope.stringValue()
                } else if field == "encryption_transformation" {
                    encTransformation = try envelope.stringValue()
                } else if field == "hashing_algorithm" {
                    hashAlgorithm = try envelope.stringValue()
                } else if field == "lock_parameters" {
                    try envelope.stepIn()
                    
                    while try envelope.hasNext() {
                        if try envelope.next() != IonUtils.TID_STRING {
                            throw DRMIonVoucherError.expectedStringListForLockParameters
                        }
                        
                        lockParams.append(try envelope.stringValue())
                    }
                    
                    try envelope.stepOut()
                }
            }
            
            try envelope.stepOut()
        }
        
        try parseVoucher()
    }
    
    private func parseVoucher() throws {
        if try !voucher.hasNext() {
            throw DRMIonVoucherError.voucherEmpty
        }
        
        if try (voucher.next() != IonUtils.TID_STRUCT || voucher.getTypeName() != "com.amazon.drm.Voucher@1.0") {
            throw DRMIonVoucherError.unknownTypeExpectedVoucher(string: try voucher.getTypeName())
        }
        
        try voucher.stepIn()
        
        while try voucher.hasNext() {
            try voucher.next()
            
            if try voucher.getFieldName() == "cipher_iv" {
                cipherIv = try voucher.lobValue()
            } else if try voucher.getFieldName() == "cipher_text" {
                cipherText = try voucher.lobValue()
            } else if try voucher.getFieldName() == "license" {
                if try voucher.getTypeName() != "com.amazon.drm.License@1.0" {
                    throw DRMIonVoucherError.unknownLicence(string: try voucher.getTypeName())
                }
                
                try voucher.stepIn()
                
                while try voucher.hasNext() {
                    try voucher.next()
                    
                    if try voucher.getFieldName() == "license_type" {
                        licenceType = try voucher.stringValue()
                    }
                }
                
                try voucher.stepOut()
            }
        }
    }
    
    func getLicenceType() -> String {
        return licenceType
    }
    
    func getSecretKey() -> Data {
        return secretKey
    }
}
