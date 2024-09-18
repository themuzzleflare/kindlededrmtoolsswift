//
//  KindleKey.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 17/9/2024.
//

#if os(macOS)
import Foundation
import Collections

final class KindleKey {
    static func getMacAddressesMunged() -> OrderedSet<Data> {
        var macNums: OrderedSet<Data> = .init()
        
        // Get the MYMACNUM environment variable
        if let macNum: String = ProcessInfo.processInfo.environment["MYMACNUM"],
           let macNumData: Data = macNum.data(using: .utf8) {
            macNums.append(macNumData)
        }
        
        // Set up the process to execute the command
        let process: Process = .init()
        process.executableURL = .init(filePath: "/usr/sbin/networksetup")
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
                print(output)
                // Split the output into lines
                let lines: [String] = output.components(separatedBy: "\n")
                
                // Process each line
                for line in lines {
                    if let range: Range<String.Index> = line.range(of: "Ethernet Address: ") {
                        // Extract the MAC address
                        let macStartIndex: String.Index = range.upperBound
                        let mac: String = line[macStartIndex...].trimmingCharacters(in: .whitespaces)
                        let macList: [String.SubSequence] = mac.split(
                            separator: ":"
                        )
                        
                        // Ensure it's a valid MAC address with 6 components
                        guard macList.count == 6 else { continue }
                        
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
                        
                        // Format the munged MAC address as a byte array
                        let mungedMacBytes: [UInt8] = mungedMac.map { .init($0) }
                        let mungedMacData: Data = .init(mungedMacBytes)
                        macNums.append(mungedMacData)
                    }
                }
            }
        } catch {
            print("Error retrieving MAC addresses: \(error.localizedDescription)")
        }
        
        // Debug output
        Debug.print("MAC addresses munged: \(macNums)")
        
        return macNums
    }
}

// MARK: - KindleKeyManager
extension KindleKey: KindleKeyManager {
    static func getUsername() -> Data {
        fatalError()
    }
    
    static func getKindleInfoFiles() -> OrderedSet<String> {
        fatalError()
    }
}
#endif
