//
//  IonUtils.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation
import KFXTables

final class IonUtils {
    static let TID_NULL: Int = 0
    static let TID_BOOLEAN: Int = 1
    static let TID_POSINT: Int = 2
    static let TID_NEGINT: Int = 3
    static let TID_FLOAT: Int = 4
    static let TID_DECIMAL: Int = 5
    static let TID_TIMESTAMP: Int = 6
    static let TID_SYMBOL: Int = 7
    static let TID_STRING: Int = 8
    static let TID_CLOB: Int = 9
    static let TID_BLOB: Int = 0xA
    static let TID_LIST: Int = 0xB
    static let TID_SEXP: Int = 0xC
    static let TID_STRUCT: Int = 0xD
    static let TID_TYPEDECL: Int = 0xE
    static let TID_UNUSED: Int = 0xF
    
    // Symbol IDs (SID)
    static let SID_UNKNOWN: Int = -1
    static let SID_ION: Int = 1
    static let SID_ION_1_0: Int = 2
    static let SID_ION_SYMBOL_TABLE: Int = 3
    static let SID_NAME: Int = 4
    static let SID_VERSION: Int = 5
    static let SID_IMPORTS: Int = 6
    static let SID_SYMBOLS: Int = 7
    static let SID_MAX_ID: Int = 8
    static let SID_ION_SHARED_SYMBOL_TABLE: Int = 9
    static let SID_ION_1_0_MAX: Int = 10
    
    // Length Indicators
    static let LEN_IS_VAR_LEN: Int = 0xE
    static let LEN_IS_NULL: Int = 0xF
    
    // Version Marker
    static let VERSION_MARKER: [Data] = .init([.init([0x01]), .init([0x00]), .init([0xEA])])
    
    static let SYM_NAMES: [String] = {
        var symnames: [String] = ["com.amazon.drm.Envelope@1.0",
                                  "com.amazon.drm.EnvelopeMetadata@1.0", "size", "page_size",
                                  "encryption_key", "encryption_transformation",
                                  "encryption_voucher", "signing_key", "signing_algorithm",
                                  "signing_voucher", "com.amazon.drm.EncryptedPage@1.0",
                                  "cipher_text", "cipher_iv", "com.amazon.drm.Signature@1.0",
                                  "data", "com.amazon.drm.EnvelopeIndexTable@1.0", "length",
                                  "offset", "algorithm", "encoded", "encryption_algorithm",
                                  "hashing_algorithm", "expires", "format", "id",
                                  "lock_parameters", "strategy", "com.amazon.drm.Key@1.0",
                                  "com.amazon.drm.KeySet@1.0", "com.amazon.drm.PIDv3@1.0",
                                  "com.amazon.drm.PlainTextPage@1.0",
                                  "com.amazon.drm.PlainText@1.0", "com.amazon.drm.PrivateKey@1.0",
                                  "com.amazon.drm.PublicKey@1.0", "com.amazon.drm.SecretKey@1.0",
                                  "com.amazon.drm.Voucher@1.0", "public_key", "private_key",
                                  "com.amazon.drm.KeyPair@1.0", "com.amazon.drm.ProtectedData@1.0",
                                  "doctype", "com.amazon.drm.EnvelopeIndexTableOffset@1.0",
                                  "enddoc", "license_type", "license", "watermark", "key", "value",
                                  "com.amazon.drm.License@1.0", "category", "metadata",
                                  "categorized_metadata", "com.amazon.drm.CategorizedMetadata@1.0",
                                  "com.amazon.drm.VoucherEnvelope@1.0", "mac", "voucher",
                                  "com.amazon.drm.ProtectedData@2.0",
                                  "com.amazon.drm.Envelope@2.0",
                                  "com.amazon.drm.EnvelopeMetadata@2.0",
                                  "com.amazon.drm.EncryptedPage@2.0",
                                  "com.amazon.drm.PlainText@2.0", "compression_algorithm",
                                  "com.amazon.drm.Compressed@1.0", "page_index_table"]
        
        // Add the range-generated entries
        for number in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 9708, 1031, 2069, 9041, 3646, 6052, 9479, 9888, 4648, 5683] {
            symnames.append("com.amazon.drm.VoucherEnvelope@\(number.description).0")
        }
        
        return symnames
    }()
    
    private init() {}
    
    static func addProtTable(ion: BinaryIonParser) {
        ion.addToCatalog(name: "ProtectedData", version: 1, symbols: SYM_NAMES)
    }
    
    static func obfuscate(secret: Data, version: Int) throws -> Data {
        var secret: Data = secret
        
        if version == 1 {
            return secret
        }
        
        let key: String = "V\(version.description)"
        guard let obfuscationData: ObfuscationValue = ObfuscationTable.get[key] else {
            throw IonUtilsError.obfuscationValueNotFound(key: key)
        }
        
        let magic: Int = obfuscationData.magicNumber
        let word: Data? = obfuscationData.word
        
        if !secret.count.isMultiple(of: magic) {
            let paddingBytes: Data = .init(count: magic - secret.count % magic)
            secret.append(paddingBytes)
        }
        
        var obfuscated: Data = .init(count: secret.count)
        let wordHash: Data = .init(HashUtils.sha256(data: word).prefix(16))
        
        for i in 0..<secret.count {
            let index: Int = (i / (secret.count / magic)) + magic * (i % (secret.count / magic))
            obfuscated[index] = secret[i] ^ wordHash[index % 16]
        }
        
        return obfuscated
    }
    
    static func scramble(st: Data, magic: Int) -> Data {
        var ret: Data = .init(count: st.count)
        let padLen: Int = st.count
        
        for counter in 0..<st.count {
            let ivar2: Int = (padLen / 2) - 2 * (counter % magic) + magic + counter - 1
            ret[ivar2 % padLen] = st[counter]
        }
        
        return ret
    }
    
    static func obfuscate2(secret: Data, version: Int) throws -> Data {
        var secret: Data = secret
        
        if version == 1 {
            return secret
        }
        
        let key: String = "V\(version.description)"
        guard let obfuscationData: ObfuscationValue = ObfuscationTable.get[key] else {
            throw IonUtilsError.obfuscationValueNotFound(key: key)
        }
        
        let magic: Int = obfuscationData.magicNumber
        let word: Data? = obfuscationData.word
        
        if !secret.count.isMultiple(of: magic) {
            let paddingBytes: Data = .init(count: magic - secret.count % magic)
            secret.append(paddingBytes)
        }
        
        var obfuscated: Data = .init(count: secret.count)
        let wordHash: Data = .init(HashUtils.sha256(data: word).suffix(16))
        let shuffled: Data = scramble(st: secret, magic: magic)
        
        for i in 0..<secret.count {
            obfuscated[i] = shuffled[i] ^ wordHash[i % 16]
        }
        
        return obfuscated
    }
    
    static func scramble3(st: Data, magic: Int) -> Data {
        var ret: Data = .init(count: st.count)
        
        let padlen: Int = st.count
        let divs: Int = padlen / magic
        
        var cntr: Int = 0
        var offset: Int = 0
        
        if 0 < ((magic - 1) + divs) {
            repeat {
                if (offset & 1) == 0 {
                    var u_var4: Int = divs - 1
                    var i_var3: Int
                    
                    if offset < divs {
                        i_var3 = 0
                        u_var4 = offset
                    } else {
                        i_var3 = (offset - divs) + 1
                    }
                    
                    if u_var4 >= 0 {
                        var i_var5: Int = u_var4 * magic
                        var index: Int = (padlen - 1) - cntr
                        
                        while true {
                            if magic <= i_var3 {
                                break
                            }
                            
                            ret[index] = st[i_var3 + i_var5]
                            i_var3 += 1
                            cntr += 1
                            u_var4 -= 1
                            i_var5 -= magic
                            index -= 1
                            
                            if u_var4 <= -1 {
                                break
                            }
                        }
                    }
                } else {
                    var i_var3: Int
                    
                    if offset < magic {
                        i_var3 = 0
                    } else {
                        i_var3 = (offset - magic) + 1
                    }
                    
                    if i_var3 < divs {
                        var u_var4: Int = offset
                        
                        if magic <= offset {
                            u_var4 = magic - 1
                        }
                        
                        var index: Int = (padlen - 1) - cntr
                        var i_var5: Int = i_var3 * magic
                        
                        while true {
                            if u_var4 < 0 {
                                break
                            }
                            
                            i_var3 += 1
                            ret[index] = st[u_var4 + i_var5]
                            u_var4 -= 1
                            index -= 1
                            i_var5 += magic
                            cntr += 1
                            
                            if i_var3 >= divs {
                                break
                            }
                        }
                    }
                }
                
                offset += 1
                
            } while offset < ((magic - 1) + divs)
        }
        
        return ret
    }
    
    static func obfuscate3(secret: Data, version: Int) throws -> Data {
        var secret: Data = secret
        
        if version == 1 {
            return secret
        }
        
        let key: String = "V\(version.description)"
        guard let obfuscationData: ObfuscationValue = ObfuscationTable.get[key] else {
            throw IonUtilsError.obfuscationValueNotFound(key: key)
        }
        
        let magic: Int = obfuscationData.magicNumber
        let word: Data? = obfuscationData.word
        
        if !secret.count.isMultiple(of: magic) {
            let paddingBytes: Data = .init(count: magic - secret.count % magic)
            secret.append(paddingBytes)
        }
        
        var obfuscated: Data = .init(count: secret.count)
        let wordHash: Data = HashUtils.sha256(data: word)
        let shuffled: Data = scramble3(st: secret, magic: magic)
        
        for i in 0..<secret.count {
            obfuscated[i] = shuffled[i] ^ wordHash[i % 16]
        }
        
        return obfuscated
    }
    
    static func processV9708(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(.init(repeating: 0x11, count: 16))
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.shuffle(repl)
            ws.sbox(d0x6a06ea70, d0x6a0dab50)
            ws.sbox(d0x6a073a70, d0x6a0dab50)
            ws.shuffle(repl)
            ws.exlookup(d0x6a072a70)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV1031(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x06, 0x18, 0x60, 0x68, 0x3B, 0x62, 0x3E, 0x3C, 0x06, 0x50, 0x71, 0x52, 0x02, 0x5A, 0x63, 0x03)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.shuffle(repl)
            ws.sbox(d0x6a0797c0, d0x6a0dab50, 3)
            ws.sbox(d0x6a07e7c0, d0x6a0dab50, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a0797c0, d0x6a0dab50, 3)
            ws.sbox(d0x6a07e7c0, d0x6a0dab50, 3)
            ws.exlookup(d0x6a07d7c0)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV2069(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x79, 0x0D, 0x12, 0x08, 0x66, 0x77, 0x2E, 0x5B, 0x02, 0x09, 0x0A, 0x13, 0x11, 0x0C, 0x11, 0x62)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a084498, d0x6a0dab50, 2)
            ws.shuffle(repl)
            ws.sbox(d0x6a089498, d0x6a0dab50, 2)
            ws.sbox(d0x6a089498, d0x6a0dab50, 2)
            ws.sbox(d0x6a084498, d0x6a0dab50, 2)
            ws.shuffle(repl)
            ws.exlookup(d0x6a088498)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV9041(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x49, 0x0b, 0x0e, 0x3b, 0x19, 0x1a, 0x49, 0x61, 0x10, 0x73, 0x19, 0x67, 0x5c, 0x1b, 0x11, 0x21)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a094170, d0x6a0dab50, 1)
            ws.shuffle(repl)
            ws.shuffle(repl)
            ws.sbox(d0x6a08f170, d0x6a0dab50, 1)
            ws.sbox(d0x6a08f170, d0x6a0dab50, 1)
            ws.sbox(d0x6a094170, d0x6a0dab50, 1)
            
            ws.exlookup(d0x6a093170)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV3646(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x0a, 0x36, 0x3e, 0x29, 0x4e, 0x02, 0x18, 0x38, 0x01, 0x36, 0x73, 0x13, 0x14, 0x1b, 0x16, 0x6a)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.shuffle(repl)
            ws.sbox(d0x6a099e48, d0x6a0dab50, 2, 3)
            ws.sbox(d0x6a09ee48, d0x6a0dab50, 2, 3)
            ws.sbox(d0x6a09ee48, d0x6a0dab50, 2, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a099e48, d0x6a0dab50, 2, 3)
            ws.sbox(d0x6a099e48, d0x6a0dab50, 2, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a09ee48, d0x6a0dab50, 2, 3)
            ws.exlookup(d0x6a09de48)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV6052(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x5f, 0x0d, 0x01, 0x12, 0x5d, 0x5c, 0x14, 0x2a, 0x17, 0x69, 0x14, 0x0d, 0x09, 0x21, 0x1e, 0x3b)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.shuffle(repl)
            ws.sbox(d0x6a0a4b20, d0x6a0dab50, 1, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a0a4b20, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0a9b20, d0x6a0dab50, 1, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a0a9b20, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0a9b20, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0a4b20, d0x6a0dab50, 1, 3)
            
            ws.exlookup(d0x6a0a8b20)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV9479(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x65, 0x1d, 0x19, 0x7c, 0x09, 0x79, 0x1d, 0x69, 0x7c, 0x4e, 0x13, 0x0e, 0x04, 0x1b, 0x6a, 0x3c)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a0af7f8, d0x6a0dab50, 1, 2, 3)
            ws.sbox(d0x6a0af7f8, d0x6a0dab50, 1, 2, 3)
            ws.sbox(d0x6a0b47f8, d0x6a0dab50, 1, 2, 3)
            ws.sbox(d0x6a0af7f8, d0x6a0dab50, 1, 2, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a0b47f8, d0x6a0dab50, 1, 2, 3)
            ws.shuffle(repl)
            ws.shuffle(repl)
            ws.sbox(d0x6a0b47f8, d0x6a0dab50, 1, 2, 3)
            ws.exlookup(d0x6a0b37f8)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV9888(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x3f, 0x17, 0x79, 0x69, 0x24, 0x6b, 0x37, 0x50, 0x63, 0x09, 0x45, 0x6f, 0x0c, 0x07, 0x07, 0x09)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a0ba4d0, d0x6a0dab50, 1, 2)
            ws.sbox(d0x6a0bf4d0, d0x6a0dab50, 1, 2)
            ws.sbox(d0x6a0bf4d0, d0x6a0dab50, 1, 2)
            ws.sbox(d0x6a0ba4d0, d0x6a0dab50, 1, 2)
            ws.shuffle(repl)
            ws.shuffle(repl)
            ws.shuffle(repl)
            ws.sbox(d0x6a0bf4d0, d0x6a0dab50, 1, 2)
            ws.sbox(d0x6a0ba4d0, d0x6a0dab50, 1, 2)
            ws.exlookup(d0x6a0be4d0)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV4648(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x16, 0x2b, 0x64, 0x62, 0x13, 0x04, 0x18, 0x0d, 0x63, 0x25, 0x14, 0x17, 0x0f, 0x13, 0x46, 0x0c)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a0ca1a8, d0x6a0dab50, 1, 3)
            ws.shuffle(repl)
            ws.sbox(d0x6a0ca1a8, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0c51a8, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0ca1a8, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0c51a8, d0x6a0dab50, 1, 3)
            ws.sbox(d0x6a0c51a8, d0x6a0dab50, 1, 3)
            ws.shuffle(repl)
            ws.shuffle(repl)
            ws.exlookup(d0x6a0c91a8)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
    
    static func processV5683(st: Data) -> Data {
        let len: Int = st.count
        let st: Data = Util.padBytes(data: st, blocklen: 16)
        
        let ws: Workspace = .init(0x7c, 0x36, 0x5c, 0x1a, 0x0d, 0x10, 0x0a, 0x50, 0x07, 0x0f, 0x75, 0x1f, 0x09, 0x3b, 0x0d, 0x72)
        
        let repl: [Int] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11]
        
        var remln: Int = st.count
        var sto: Int = 0
        
        var out: Data = .init()
        
        while remln > 0 {
            ws.sbox(d0x6a0d4e80, d0x6a0dab50)
            ws.shuffle(repl)
            ws.sbox(d0x6a0cfe80, d0x6a0dab50)
            ws.sbox(d0x6a0d4e80, d0x6a0dab50)
            ws.sbox(d0x6a0cfe80, d0x6a0dab50)
            ws.sbox(d0x6a0d4e80, d0x6a0dab50)
            ws.shuffle(repl)
            ws.sbox(d0x6a0cfe80, d0x6a0dab50)
            ws.shuffle(repl)
            ws.exlookup(d0x6a0d3e80)
            
            out.append(ws.mask(st.subdata(in: sto..<sto + 16)))
            
            sto += 16
            remln -= 16
        }
        
        return out.subdata(in: 0..<len)
    }
}

// MARK: - Convenience Methods
extension IonUtils {
    static func addProtTable(_ ion: BinaryIonParser) {
        addProtTable(ion: ion)
    }
    
    static func obfuscate(_ secret: Data, _ version: Int) throws -> Data {
        return try obfuscate(secret: secret, version: version)
    }
    
    static func obfuscate2(_ secret: Data, _ version: Int) throws -> Data {
        return try obfuscate2(secret: secret, version: version)
    }
    
    static func obfuscate3(_ secret: Data, _ version: Int) throws -> Data {
        return try obfuscate3(secret: secret, version: version)
    }
    
    static func processV9708(_ st: Data) -> Data {
        return processV9708(st: st)
    }
    
    static func processV1031(_ st: Data) -> Data {
        return processV1031(st: st)
    }
    
    static func processV2069(_ st: Data) -> Data {
        return processV2069(st: st)
    }
    
    static func processV9041(_ st: Data) -> Data {
        return processV9041(st: st)
    }
    
    static func processV3646(_ st: Data) -> Data {
        return processV3646(st: st)
    }
    
    static func processV6052(_ st: Data) -> Data {
        return processV6052(st: st)
    }
    
    static func processV9479(_ st: Data) -> Data {
        return processV9479(st: st)
    }
    
    static func processV9888(_ st: Data) -> Data {
        return processV9888(st: st)
    }
    
    static func processV4648(_ st: Data) -> Data {
        return processV4648(st: st)
    }
    
    static func processV5683(_ st: Data) -> Data {
        return processV5683(st: st)
    }
}
