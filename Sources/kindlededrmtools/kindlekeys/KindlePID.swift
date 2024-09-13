//
//  KindlePID.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation
import Collections

enum KindlePID {
    // Returns two bits at offset from a bit field
    private static func getTwoBitsFromBitField(bitField: Data, offset: Int) -> Int {
        let byteNumber: Int = offset / 4
        let bitPosition: Int = 6 - 2 * (offset % 4)
        
        return .init(bitField[byteNumber] >> bitPosition) & 3
    }
    
    // Returns six bits at the given offset from a bit field
    private static func getSixBitsFromBitField(bitField: Data, offset: Int) -> Int {
        let newOffset: Int = offset * 3
        
        return (getTwoBitsFromBitField(bitField: bitField, offset: newOffset) << 4) +
        (getTwoBitsFromBitField(bitField: bitField, offset: newOffset + 1) << 2) +
        getTwoBitsFromBitField(bitField: bitField, offset: newOffset + 2)
    }
    
    // 8 bits to six bits encoding from hash to generate PID string
    private static func encodePid(hashVal: Data) -> Data {
        var result: Data = .init()
        
        for i in 0..<8 {
            let sixBits: Int = getSixBitsFromBitField(bitField: hashVal, offset: i)
            result.append(CharMaps.charMap3[sixBits])
        }
        
        return result
    }
    
    // Seed value used to generate the device PID
    private static func generatePidSeed(table: [Int], dsn: Data) -> Int {
        var value: Int = 0
        
        for counter in 0..<4 {
            let index: Int = .init((dsn[counter] ^ .init(value & 0xFF)))
            value = (value >> 8) ^ table[index]
        }
        
        return value
    }
    
    // Generate the device PID
    private static func generateDevicePid(table: [Int], dsn: Data, nbRoll: Int) -> Data {
        // Generate the seed
        let seed: Int = generatePidSeed(table: table, dsn: dsn)
        
        var pidAscii: Data = .init()
        
        // Initialize the pid array
        var pid: [Int] = [
            (seed >> 24) & 0xFF, (seed >> 16) & 0xFF, (seed >> 8) & 0xFF, seed & 0xFF,
            (seed >> 24) & 0xFF, (seed >> 16) & 0xFF, (seed >> 8) & 0xFF, seed & 0xFF
        ]
        
        var index: Int = 0
        
        // Apply rolling operation using DSN and nbRoll
        for counter in 0..<nbRoll {
            pid[index] = pid[index] ^ .init(dsn[counter] & 0xFF) // XOR with DSN
            index = (index + 1) % 8
        }
        
        // Convert pid to encoded ASCII using the charMap4
        for counter in 0..<8 {
            index = ((((pid[counter] >> 5) & 3) ^ pid[counter]) & 0x1F) + (pid[counter] >> 7)
            pidAscii.append(CharMaps.charMap4[index])
        }
        
        return pidAscii
    }
    
    // Generate the encryption table used to generate the device PID
    private static func generatePidEncryptionTable() -> [Int] {
        var table: [Int] = .init()
        
        for counter1 in 0..<0x100 {
            var value: Int = counter1
            
            for _ in 0..<8 {
                if (value & 1) == 0 {
                    value = value >> 1 // Logical right shift (unsigned shift)
                } else {
                    value = value >> 1 // Logical right shift (unsigned shift)
                    value = value ^ 0xEDB88320
                }
            }
            
            table.append(value)
        }
        
        return table
    }
    
    private static func pidFromSerial(serial: Data, length: Int) -> Data {
        let crc: Int = .init(KindleKeyUtils.crc32(data: serial))
        
        // Initialize arr1 with length `length` and fill with zeros
        var arr1: [Int] = .init(repeating: 0, count: length)
        
        // XOR each byte of `serial` with `arr1`
        for i in 0..<serial.count {
            arr1[i % length] ^= .init(serial[i])
        }
        
        // Extract the CRC bytes
        let crcBytes: [Int] = [
            (crc >> 24) & 0xff,
            (crc >> 16) & 0xff,
            (crc >> 8) & 0xff,
            crc & 0xff
        ]
        
        // XOR `arr1` with `crcBytes`
        for i in 0..<length {
            arr1[i] ^= crcBytes[i & 3]
        }
        
        var pid: Data = .init()
        
        // Convert arr1 to encoded ASCII using `charMap4`
        for i in 0..<length {
            let b: Int = arr1[i] & 0xff
            let charIndex: Int = (b >> 7) + ((b >> 5 & 3) ^ (b & 0x1f))
            pid.append(CharMaps.charMap4[charIndex])
        }
        
        return pid
    }
    
    private static func getK4Pids(rec209: Data?, token: Data?, kDatabaseRecord: KDatabaseRecord) -> OrderedSet<String> {
        return .init()
    }
    
    private static func getKindlePids(rec209: Data?, token: Data?, serialnum: String) -> OrderedSet<String> {
        let serialnum: Data = serialnum.data(using: .utf8) ?? .init()
        return getKindlePids(rec209: rec209, token: token, serialnum: serialnum)
    }
    
    private static func getKindlePids(rec209: Data?, token: Data?, serialnum: Data) -> OrderedSet<String> {
        var pids: OrderedSet<String> = .init()
        
        let serialnumString: String = .init(data: serialnum, encoding: .utf8) ?? ""
        
        guard let rec209 else {
            pids.append(serialnumString)
            return pids
        }
        
        let bookPidHash: Data = HashUtils.sha1(data: serialnum, rec209, token)
        var bookPid: Data = encodePid(hashVal: bookPidHash)
        bookPid = KindleKeyUtils.checksumPid(data: bookPid, charMap: CharMaps.charMap4)
        
        let bookPidString: String = .init(data: bookPid, encoding: .utf8) ?? ""
        pids.append(bookPidString)
        
        var kindlePidResult: Data = .init()
        
        kindlePidResult.append(pidFromSerial(serial: serialnum, length: 7))
        kindlePidResult.append(CharMaps.asteriskBytes)
        
        let kindlePid: Data = KindleKeyUtils.checksumPid(data: kindlePidResult, charMap: CharMaps.charMap4)
        let kindlePidString: String = .init(data: kindlePid, encoding: .utf8) ?? ""
        pids.append(kindlePidString)
        
        return pids
    }
    
    static func getPidSet(rec209: Data?, token: Data?, serials: OrderedSet<String>, kDatabaseRecords: OrderedSet<KDatabaseRecord>) -> OrderedSet<String> {
        var pids: OrderedSet<String> = .init()
        
        for kDatabaseRecord in kDatabaseRecords {
            let k4Pids: OrderedSet<String> = getK4Pids(rec209: rec209, token: token, kDatabaseRecord: kDatabaseRecord)
            pids.append(contentsOf: k4Pids)
        }
        
        for serial in serials {
            let kindlePids: OrderedSet<String> = getKindlePids(rec209: rec209, token: token, serialnum: serial)
            pids.append(contentsOf: kindlePids)
        }
        
        return pids
    }
}
