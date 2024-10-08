//
//  KindleKeyMacOS.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 17/9/2024.
//

#if os(macOS)
import Foundation
import OrderedCollections

final class KindleKeyMacOS: KindleKey {
    private static let charMap2: Data = "ZB0bYyc1xDdW2wEV3Ff7KkPpL8UuGA4gz-Tme9Nn_tHh5SvXCsIiR6rJjQaqlOoM".data(using: .ascii)!
    private static let charMap5 = charMap2
    
    override func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data> {
        var db: OrderedDictionary<String, Data> = .init()
        
        let url: URL = Util.url(filePath: kinfoFile)
        let fileData: Data = try .init(contentsOf: url)
        
        let data: Data = .init(fileData.prefix(fileData.count - 1))
        
        var items: [String] = .init()
        let idStrings: OrderedSet<Data> = KindleKeyMacOS.getIdStrings()
        
        print("trying username", getUsername().formattedForOutput, "on file", kinfoFile)
        
        var foundIdString: Data?
        
        for idString in idStrings {
            print("trying IDString:", idString.formattedForOutput)
            
            do {
                db.removeAll()
                
                guard let dataString: String = .init(data: data, encoding: .utf8) else {
                    throw KindleKeyError.stringFromDataFailed(data: data)
                }
                
                items = dataString.components(separatedBy: "/")
                
                let headerblob: String = items.removeFirst()
                
                guard let headerblobData: Data = headerblob.data(using: .utf8) else {
                    throw KindleKeyError.dataFromStringFailed(string: headerblob)
                }
                
                var encryptedValue: Data = KindleKeyUtils.decode(data: headerblobData, map: CharMaps.charMap1)
                let cleartext: Data = try KindleKey.unprotectHeaderData(encryptedData: encryptedValue)
                
                guard let cleartextString: String = .init(data: cleartext, encoding: .utf8) else {
                    throw KindleKeyError.stringFromDataFailed(data: cleartext)
                }
                
                let pattern: String = #"\[Version:(\d+)]\[Build:(\d+)]\[Cksum:([^]]+)]\[Guid:([{}a-z0-9\-]+)]"#
                
                let regex: NSRegularExpression = try .init(pattern: pattern, options: .caseInsensitive)
                
                let range: NSRange = .init(cleartextString.startIndex..., in: cleartextString)
                let matches: [NSTextCheckingResult] = regex.matches(in: cleartextString, options: [], range: range)
                
                // Initialize variables
                var version: Int = 0
                var build: String = ""
                var guid: String = ""
                
                for match in matches {
                    // Extract version (Group 1)
                    if let versionRange: Range<String.Index> = .init(match.range(at: 1), in: cleartextString) {
                        let versionString: String = .init(cleartextString[versionRange])
                        version = .init(versionString) ?? 0
                    }
                    
                    // Extract build (Group 2)
                    if let buildRange: Range<String.Index> = .init(match.range(at: 2), in: cleartextString) {
                        build = .init(cleartextString[buildRange])
                    }
                    
                    // Extract guid (Group 4)
                    if let guidRange: Range<String.Index> = .init(match.range(at: 4), in: cleartextString) {
                        guid = .init(cleartextString[guidRange])
                    }
                }
                
                var cud: CryptUnprotectData! = nil
                var key: Data! = nil
                
                if version == 5 {
                    Debug.print("version 5")
                    
                    guard let buildInt: Int = .init(build) else {
                        throw KindleKeyError.stringToIntFailed(string: build)
                    }
                    
                    // Step 2: Multiply by 0x2df (735)
                    let multiplier: Int = 0x2df // 735 in decimal
                    let multipliedValue: Int = multiplier * buildInt
                    
                    // Step 3: Convert the result to a String
                    let multipliedString: String = .init(multipliedValue)
                    
                    // Step 4: Concatenate the result with `guid`
                    let concatenatedString: String = multipliedString + guid
                    
                    // Step 5: Convert the concatenated string to Data using UTF-8 encoding
                    guard let entropy: Data = concatenatedString.data(using: .utf8) else {
                        // Handle error: Unable to convert string to data
                        throw KindleKeyError.dataFromStringFailed(string: concatenatedString)
                    }
                    
                    cud = try .init(entropy: entropy, idString: idString, username: getUsername())
                } else if version == 6 {
                    Debug.print("version 6")
                    
                    guard let buildInt: Int = .init(build) else {
                        throw KindleKeyError.stringToIntFailed(string: build)
                    }
                    
                    let multiplier: Int = 0x6d8
                    let multipliedValue: Int = multiplier * buildInt
                    
                    let multipliedString: String = .init(multipliedValue)
                    
                    let concatenatedString: String = multipliedString + guid
                    
                    guard let salt: Data = concatenatedString.data(using: .utf8) else {
                        throw KindleKeyError.dataFromStringFailed(string: concatenatedString)
                    }
                    
                    let sp: Data = getUsername() + "+@#$%+".data(using: .utf8)! + idString
                    let passwd: Data = KindleKeyUtils.encode(HashUtils.sha256(sp), KindleKeyMacOS.charMap5)
                    
                    let localKey: Data = try CryptoUtils.pbkdf2hmacsha1(passwd, salt, 10000, 0x400)
                    key = .init(localKey.prefix(32))
                    
                    Debug.print("salt:", salt.formattedForOutput)
                    Debug.print("sp:", sp.formattedForOutput)
                    Debug.print("passwd:", passwd.formattedForOutput)
                    Debug.print("key:", key.formattedForOutput)
                }
                
                while !items.isEmpty {
                    let item: String = items.removeFirst()
                    
                    let itemStr: String = .init(item.prefix(32))
                    guard let keyHash: Data = itemStr.data(using: .utf8) else {
                        throw KindleKeyError.dataFromStringFailed(string: itemStr)
                    }
                    
                    let srcntItemSubstringStartingIndex = item.index(item.startIndex, offsetBy: 34)
                    let srcntItemSubstring: String = .init(item[srcntItemSubstringStartingIndex...])
                    
                    guard let srcntItemSubstrData: Data = srcntItemSubstring.data(using: .utf8) else {
                        throw KindleKeyError.dataFromStringFailed(string: srcntItemSubstring)
                    }
                    
                    let srcnt: Data = KindleKeyUtils.decode(srcntItemSubstrData, KindleKeyMacOS.charMap5)
                    
                    guard let srcntString: String = String(data: srcnt, encoding: .utf8) else {
                        throw KindleKeyError.stringFromDataFailed(data: srcnt)
                    }
                    
                    guard let rcnt: Int = .init(srcntString) else {
                        throw KindleKeyError.stringToIntFailed(string: srcntString)
                    }
                    
                    Debug.print("keyHash:", keyHash.formattedForOutput)
                    Debug.print("srcnt:", srcnt.formattedForOutput)
                    Debug.print("rcnt:", rcnt.description)
                    
                    var edlst: Data = .init()
                    
                    for _ in 0..<rcnt {
                        let record: String = items.removeFirst()
                        
                        guard let recordData: Data = record.data(using: .utf8) else {
                            throw KindleKeyError.dataFromStringFailed(string: record)
                        }
                        
                        edlst.append(recordData)
                    }
                    
                    var keyname: String = "unknown"
                    
                    for name in KindleDatabase.keyBytesList {
                        let encodedHash: Data = KindleKeyUtils.encodeHash(data: name, charMap: CharMaps.testMap8)
                        
                        if encodedHash == keyHash {
                            guard let keynameStr: String = .init(data: name, encoding: .utf8) else {
                                throw KindleKeyError.stringFromDataFailed(data: name)
                            }
                            
                            keyname = keynameStr
                            break
                        }
                    }
                    
                    if keyname == "unknown" {
                        guard let keynameStr: String = .init(data: keyHash, encoding: .utf8) else {
                            throw KindleKeyError.stringFromDataFailed(data: keyHash)
                        }
                        
                        keyname = keynameStr
                    }
                    
                    Debug.print("keyName:", keyname)
                    
                    var encdata: Data = edlst
                    
                    Debug.print("encdata:", encdata.formattedForOutput)
                    
                    let primesList: [Int] = KindleKey.primes(n: encdata.count / 3)
                    let noffset: Int = encdata.count - primesList.last!
                    
                    let pfx: Data = .init(encdata.prefix(noffset))
                    let suffix: Data = encdata.subdata(in: noffset..<encdata.count)
                    
                    encdata = suffix + pfx
                    
                    Debug.print("encdata:", encdata.formattedForOutput)
                    
                    var clearText: Data?
                    
                    if version == 5 {
                        Debug.print("version 5")
                        
                        encryptedValue = KindleKeyUtils.decode(encdata, CharMaps.testMap8)
                        clearText = try cud.decrypt(encryptedValue)
                    } else if version == 6 {
                        Debug.print("version 6")
                        
                        let ivCiphertext: Data = KindleKeyUtils.decode(encdata, CharMaps.testMap8)
                        let iv: Data = Data(ivCiphertext.prefix(12)) + Data([0x00, 0x00, 0x00, 0x02])
                        let ciphertext: Data = ivCiphertext.subdata(in: 12..<ivCiphertext.count)
                        
                        Debug.print("ivCiphertext:", ivCiphertext.formattedForOutput)
                        Debug.print("iv:", iv.formattedForOutput)
                        Debug.print("ciphertext:", ciphertext.formattedForOutput)
                        
                        let decrypted: Data = try CryptoUtils.aesctrdecrypt(key, iv, ciphertext)
                        
                        Debug.print("decrypted:", decrypted.formattedForOutput)
                        
                        clearText = KindleKeyUtils.decode(decrypted, KindleKeyMacOS.charMap5)
                        
                        Debug.print("clearText:", clearText.formattedForOutput)
                    }
                    
                    if let clearText, !clearText.isEmpty {
                        db[keyname] = clearText
                    }
                }
                
                if db.count > 6 {
                    foundIdString = idString
                    break
                }
            } catch {
                print("Error occurred while decrypting key file '\(kinfoFile)' with IDString '\(idString.formattedForOutput)' and UserName '\(getUsername().formattedForOutput)': \(error.localizedDescription)")
            }
        }
        
        if let foundIdString {
            db["IDString"] = foundIdString
            db["UserName"] = getUsername()
            
            print("Decrypted key file using IDString '\(foundIdString.formattedForOutput)' and UserName '\(getUsername().formattedForOutput)'")
        } else {
            
        }
        
        return db
    }
    
    override func getUsername() -> Data {
        guard let username: String = ProcessInfo.processInfo.environment["USER"],
              let usernameData = username.data(using: .utf8) else {
            return .init()
        }
        
        Debug.print("Username:", usernameData.formattedForOutput)
        
        return usernameData
    }
    
    override func getKindleInfoFiles() -> OrderedSet<String> {
        var kInfoFiles: OrderedSet<String> = .init()
        
        guard let home: String = ProcessInfo.processInfo.environment["HOME"] else {
            return kInfoFiles
        }
        
        let pathsToCheck: OrderedSet<KindlePath> = KindlePath.getKindlePaths(homeDir: home)
        
        for testPath in pathsToCheck {
            KindleKeyMacOS.checkAndAddFile(testPath: testPath, kInfoFiles: &kInfoFiles)
        }
        
        if kInfoFiles.isEmpty {
            print("No k4Mac kindle-info/rainier/kinf2011/kinf2018 files have been found.")
        }
        
        return kInfoFiles
    }
    
    static func getMacAddressesMunged() -> OrderedSet<Data> {
        var macNums: OrderedSet<Data> = .init()
        
        // Get the MYMACNUM environment variable
        if let macNum: String = ProcessInfo.processInfo.environment["MYMACNUM"],
           let macNumData: Data = macNum.data(using: .utf8) {
            macNums.append(macNumData)
        }
        
        // Set up the process to execute the command
        let process: Process = .init()
        process.executableURL = Util.url(filePath: "/usr/sbin/networksetup")
        process.arguments = ["-listallhardwareports"]
        
        let pipe: Pipe = .init()
        process.standardOutput = pipe
        
        do {
            // Execute the command
            try process.run()
            
            process.waitUntilExit()
            
            // Read the output data
            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            // Convert output data to a string
            if let output: String = .init(data: data, encoding: .utf8) {
                // Split the output into lines
                let lines: [String] = output.components(separatedBy: .newlines)
                
                // Process each line
                for line in lines {
                    if let range: Range<String.Index> = line.range(of: "Ethernet Address: ") {
                        // Extract the MAC address
                        let mac: String = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                        let macList: [String.SubSequence] = mac.split(separator: ":")
                        
                        // Ensure it's a valid MAC address with 6 components
                        guard macList.count == 6 else {
                            continue
                        }
                        
                        // Convert MAC address parts to integers
                        var macIntList: [Int] = .init()
                        var isValidMac: Bool = true
                        
                        for macPart in macList {
                            if let macInt: Int = .init(macPart, radix: 16) {
                                macIntList.append(macInt)
                            } else {
                                isValidMac = false
                                break
                            }
                        }
                        
                        if !isValidMac { continue }
                        
                        // Munging the MAC address by XOR with 0xa5 and swapping elements
                        var mungedMac: [Int] = .init(repeating: 0, count: 6)
                        
                        mungedMac[5] = macIntList[5] ^ 0xa5
                        mungedMac[4] = macIntList[3] ^ 0xa5
                        mungedMac[3] = macIntList[4] ^ 0xa5
                        mungedMac[2] = macIntList[2] ^ 0xa5
                        mungedMac[1] = macIntList[1] ^ 0xa5
                        mungedMac[0] = macIntList[0] ^ 0xa5
                        
                        let mungedMacStr: String = .init(format: "%02x%02x%02x%02x%02x%02x", mungedMac[0], mungedMac[1], mungedMac[2], mungedMac[3], mungedMac[4], mungedMac[5])
                        
                        guard let mungedMacData: Data = mungedMacStr.data(using: .utf8) else { continue }
                        
                        macNums.append(mungedMacData)
                    }
                }
            }
        } catch {
            print("Error retrieving MAC addresses:", error.localizedDescription)
        }
        
        // Debug output
        Debug.print("MAC addresses munged:", macNums.description)
        
        return macNums
    }
    
    static func getVolumeSerialNumbers() -> OrderedSet<Data> {
        var serNums: OrderedSet<Data> = .init()
        
        if let serNum: String = ProcessInfo.processInfo.environment["MYSERIALNUMBER"],
           !serNum.isEmpty,
           let serNumData: Data = serNum.trimmingCharacters(in: .whitespaces).data(using: .utf8) {
            serNums.append(serNumData)
        }
        
        getVolumeSerialNumbersViaIoreg(serNums: &serNums)
        getVolumeSerialNumbersViaSystemProfiler(serNums: &serNums)
        
        Debug.print("Volume serial numbers:", serNums.description)
        
        return serNums
    }
    
    private static func getVolumeSerialNumbersViaIoreg(serNums: inout OrderedSet<Data>) {
        let process: Process = .init()
        process.executableURL = Util.url(filePath: "/usr/sbin/ioreg")
        process.arguments = ["-w", "0", "-r"]
        
        for storageDriveClass in IORegStorageDriveClasses.allCases {
            process.arguments?.append("-c")
            process.arguments?.append(storageDriveClass.rawValue)
        }
        
        let pipe: Pipe = .init()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output: String = .init(data: data, encoding: .utf8) {
                let lines: [String] = output.components(separatedBy: .newlines)
                
                for line in lines {
                    if let range: Range<String.Index> = line.range(of: "\"Serial Number\" = \"") {
                        var serial: String = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                        
                        if serial.hasSuffix("\"") {
                            let index: String.Index = serial.index(before: serial.endIndex)
                            serial.removeSubrange(index..<serial.endIndex)
                        }
                        
                        if let serialData: Data = serial.data(using: .utf8) {
                            serNums.append(serialData)
                        }
                    }
                }
            }
        } catch {
            print("Error retrieving volume serial numbers via ioreg:", error.localizedDescription)
        }
    }
    
    private static func getVolumeSerialNumbersViaSystemProfiler(serNums: inout OrderedSet<Data>) {
        let process: Process = .init()
        process.executableURL = Util.url(filePath: "/usr/sbin/system_profiler")
        process.arguments = SystemProfilerStorageDriveDataTypes.allCases.map(\.rawValue)
        
        let pipe: Pipe = .init()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output: String = .init(data: data, encoding: .utf8) {
                let lines: [String] = output.components(separatedBy: .newlines)
                
                for line in lines {
                    if let range: Range<String.Index> = line.range(of: "Serial Number: ") {
                        let serial: String = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                        
                        if let serialData: Data = serial.data(using: .utf8) {
                            serNums.append(serialData)
                        }
                    }
                }
            }
        } catch {
            print("Error retrieving volume serial numbers via system_profiler:", error.localizedDescription)
        }
    }
    
    static func getDiskPartitionNames() -> OrderedSet<Data> {
        var names: OrderedSet<Data> = .init()
        
        let process: Process = .init()
        process.executableURL = Util.url(filePath: "/sbin/mount")
        
        let pipe: Pipe = .init()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output: String = .init(data: data, encoding: .utf8) {
                let lines: [String] = output.components(separatedBy: .newlines)
                
                for line in lines {
                    if line.starts(with: "/dev") {
                        let parts: [String] = line.components(separatedBy: " on ")
                        
                        if parts.count > 0 {
                            let index: String.Index = parts[0].index(parts[0].startIndex, offsetBy: 5)
                            let partitionName: String = .init(parts[0][index...])
                            
                            names.append(.init(partitionName.utf8))
                        }
                    }
                }
            }
        } catch {
            print("Error retrieving disk partition names:", error.localizedDescription)
        }
        
        Debug.print("Disk partition names:", names.description)
        
        return names
    }
    
    static func getDiskPartitionUUIDs() -> OrderedSet<Data> {
        var uuids: OrderedSet<Data> = .init()
        
        if let uuidNum: String = ProcessInfo.processInfo.environment["MYUUIDNUMBER"],
           let uuidNumData: Data = uuidNum.trimmingCharacters(in: .whitespaces).data(using: .utf8) {
            uuids.append(uuidNumData)
        }
        
        let process: Process = .init()
        process.executableURL = Util.url(filePath: "/usr/sbin/ioreg")
        process.arguments = ["-l", "-S", "-w", "0", "-r"]
        
        for storageDriveClass in IORegStorageDriveClasses.allCases {
            process.arguments?.append("-c")
            process.arguments?.append(storageDriveClass.rawValue)
        }
        
        let pipe: Pipe = .init()
        process.standardOutput = pipe
        
        do {
            try process.run()
            
            //            process.waitUntilExit()
            
            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output: String = .init(data: data, encoding: .utf8) {
                let lines: [String] = output.components(separatedBy: .newlines)
                
                for line in lines {
                    if let range: Range<String.Index> = line.range(of: "\"UUID\" = \"") {
                        var uuid: String = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                        
                        if uuid.hasSuffix("\"") {
                            let index: String.Index = uuid.index(before: uuid.endIndex)
                            uuid.removeSubrange(index..<uuid.endIndex)
                        }
                        
                        if let uuidData: Data = uuid.data(using: .utf8) {
                            uuids.append(uuidData)
                        }
                    }
                }
            }
        } catch {
            print("Error retrieving disk partition UUIDs:", error.localizedDescription)
        }
        
        Debug.print("Disk partition UUIDs:", uuids.description)
        
        return uuids
    }
    
    static func getIdStrings() -> OrderedSet<Data> {
        var ids: OrderedSet<Data> = .init()
        
        ids.append(contentsOf: getMacAddressesMunged())
        ids.append(contentsOf: getVolumeSerialNumbers())
        ids.append(contentsOf: getDiskPartitionNames())
        ids.append(contentsOf: getDiskPartitionUUIDs())
        
        ids.append(.init("9999999999".utf8))
        
        return ids
    }
    
    private static func checkAndAddFile(testPath: KindlePath, kInfoFiles: inout OrderedSet<String>) {
        if FileManager.default.fileExists(atPath: testPath.path) {
            print("Found", testPath.description)
            kInfoFiles.append(testPath.path)
        }
    }
}

extension KindleKeyMacOS {
    private class CryptUnprotectData {
        private let key: Data
        private let iv: Data
        
        init(entropy: Data, idString: Data, username: Data) throws {
            // Step 1: Concatenate username, "+@#$%+", and idString
            let usernameData = username
            let separator = "+@#$%+".data(using: .utf8)!
            let sp = usernameData + separator + idString
            
            // Step 2: Compute SHA-256 hash of the concatenated data
            let sha256Hash = HashUtils.sha256(data: sp)
            
            // Step 3: Encode the hash using a custom method and character map
            let passwdData = KindleKeyUtils.encode(data: sha256Hash, charMap: charMap2)
            
            // Step 4: Use PBKDF2 with HMAC SHA-1 to derive the key and IV
            let salt = entropy
            let keyLength = 48 // 32 bytes for key + 16 bytes for IV
            let iterations = 0x800 // 2048 iterations
            let keyIv = try CryptoUtils.pbkdf2hmacsha1(password: passwdData, salt: salt, iterationCount: iterations, keyLength: keyLength)
            
            // Step 5: Split the derived key into the AES key and IV
            self.key = keyIv.subdata(in: 0..<32)
            self.iv = keyIv.subdata(in: 32..<48)
        }
        
        func decrypt(_ encryptedData: Data) throws -> Data {
            // Step 6: Decrypt the data using AES/CBC/PKCS5Padding
            let decryptedData = try CryptoUtils.aescbcdecrypt(key: self.key, iv: self.iv, cipherText: encryptedData)
            
            // Step 7: Decode the decrypted data using a custom method and character map
            return KindleKeyUtils.decode(data: decryptedData, map: charMap2)
        }
    }
}
#endif
