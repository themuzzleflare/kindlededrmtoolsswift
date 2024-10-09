//
//  KindleKey.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 8/10/2024.
//

#if os(macOS) || os(Windows)
import Foundation
import OrderedCollections
import CryptoSwift

class KindleKey: KindleKeyManager {
    static func getManager() throws -> some KindleKeyManager {
#if os(macOS)
        return KindleKeyMacOS()
#elseif os(Windows)
        return KindleKeyWindows()
#else
        throw KindleKeyError.unsupportedOperatingSystem
#endif
    }
    
    func getUsername() throws -> Data {
        fatalError("Must be overridden")
    }
    
    func getKindleInfoFiles() throws -> OrderedSet<String> {
        fatalError("Must be overridden")
    }
    
    func getDbFromFile(kinfoFile: String) throws -> OrderedDictionary<String, Data> {
        fatalError("Must be overridden")
    }
    
    static func unprotectHeaderData(encryptedData: Data) throws -> Data {
        Debug.print("Encrypted data:", encryptedData.formattedForOutput)
        
        let headerKeyDataStr: String = "header_key_data"
        guard let passwdData: Data = headerKeyDataStr.data(using: .ascii) else {
            throw KindleKeyError.dataFromStringFailed(string: headerKeyDataStr)
        }
        
        let header2011Str: String = "HEADER.2011"
        guard let salt: Data = header2011Str.data(using: .ascii) else {
            throw KindleKeyError.dataFromStringFailed(string: header2011Str)
        }
        
        let keyIv: Data = try CryptoUtils.pbkdf2hmacsha1(password: passwdData, salt: salt, iterationCount: 128, keyLength: 256)
        
        Debug.print("Derived key:", keyIv.formattedForOutput)
        
        // Extract the AES key and IV from the derived key material
        let key: Data = keyIv.subdata(in: 0..<32) // First 32 bytes for AES key
        let iv: Data = keyIv.subdata(in: 32..<48) // Next 16 bytes for IV
        
        // Decrypt the data
        let decryptedData: Data = try CryptoUtils.aescbcdecrypt(key: key, iv: iv, cipherText: encryptedData)
        
        Debug.print("Decrypted data:", decryptedData.formattedForOutput)
        
        return decryptedData
    }
    
    static func primes(n: Int) -> [Int] {
        if n == 2 {
            return [2]
        } else if n < 2 {
            return .init()
        }
        
        var primeList: [Int] = [2]
        
        for potentialPrime in stride(from: 3, through: n, by: 2) {
            var isItPrime: Bool = true
            
            for prime in primeList {
                if potentialPrime % prime == 0 {
                    isItPrime = false
                    break
                }
            }
            
            if isItPrime {
                primeList.append(potentialPrime)
            }
        }
        
        return primeList
    }
    
    final func kindleKeys(files: OrderedSet<String>) throws -> OrderedSet<KindleDatabase> {
        var files: OrderedSet<String> = files
        
        if Util.practicalIsEmpty(set: files) {
            files = try getKindleInfoFiles()
        }
        
        var keys: OrderedSet<KindleDatabase> = .init()
        
        for file in files {
            let key: OrderedDictionary<String, Data> = try getDbFromFile(kinfoFile: file)
            
            if !key.isEmpty {
                var nKey: KindleDatabase = .init()
                
                for (key, value) in key {
                    let keyName: String = key
                    let hexValue: String = value.hexString
                    
                    nKey[keyName] = hexValue
                }
                
                keys.append(nKey)
            }
        }
        
        return keys
    }
    
    final func getKeyThrowing(outpath: String, files: OrderedSet<String>? = nil) throws {
        // Check if files list is null, and initialise it if necessary
        let files: OrderedSet<String> = Util.sanitiseSet(files)
        
        // Retrieve Kindle keys using the kindleKeys method
        let keys: OrderedSet<KindleDatabase> = try kindleKeys(files: files)
        
        if !keys.isEmpty {
            let outFile: URL = Util.url(filePath: outpath)
            
            // Check if the output path is a directory or a file
            if !outFile.hasDirectoryPath {
                // If it's not a directory, assume it's a file path
                do {
                    // Write the first key to the specified file
                    try keys.first?.writeToFile(url: outFile)
                    print("Saved a key to", Util.urlPath(url: outFile, percentEncoded: false))
                } catch {
                    print("Error saving key to file:", error.localizedDescription)
                    throw error
                }
            } else {
                // If it's a directory, save each key to a separate file with a unique name
                var keyCount: Int = 0
                
                for key in keys {
                    while true {
                        keyCount += 1
                        
                        let outfile: URL = Util.appending(base: outFile, add: "kindlekey\(keyCount.description).k4i")
                        let outfilePath: String = Util.urlPath(url: outfile, percentEncoded: false)
                        
                        // Check if the file already exists
                        if !FileManager.default.fileExists(atPath: outfilePath) {
                            do {
                                try key.writeToFile(url: outfile)
                                print("Saved a key to", outfilePath)
                            } catch {
                                print("Error saving key to file:", error.localizedDescription)
                                throw error
                            }
                            
                            break
                        }
                    }
                }
            }
            
            return
        }
        
        throw KindleKeyError.noKeysFound
    }
}
#endif
