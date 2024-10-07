//
//  KindleKeyMacOS.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 17/9/2024.
//

#if os(macOS)
import Foundation
import OrderedCollections

final class KindleKeyMacOS {
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
                        let macList: [String.SubSequence] = mac.split(
                            separator: ":"
                        )
                        
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
            print("Error retrieving MAC addresses: \(error.localizedDescription)")
        }
        
        // Debug output
        Debug.print("MAC addresses munged:", macNums)
        
        return macNums
    }
    
    static func getVolumeSerialNumbers() -> OrderedSet<Data> {
        var serNums: OrderedSet<Data> = []
        
        if let serNum: String = ProcessInfo.processInfo.environment["MYSERIALNUMBER"],
           !serNum.isEmpty,
           let serNumData: Data = serNum.trimmingCharacters(in: .whitespaces).data(using: .utf8) {
            serNums.append(serNumData)
        }
        
        getVolumeSerialNumbersViaIoreg(serNums: &serNums)
        getVolumeSerialNumbersViaSystemProfiler(serNums: &serNums)
        
        Debug.print("Volume serial numbers", serNums)
        
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
            print("Error retrieving volume serial numbers via ioreg: \(error.localizedDescription)")
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
            print("Error retrieving volume serial numbers via system_profiler: \(error.localizedDescription)")
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
            print("Error retrieving disk partition names: \(error.localizedDescription)")
        }
        
        Debug.print("Disk partition names:", names)
        
        return names
    }
    
    static func getDiskPartitionUUIDs() -> OrderedSet<Data> {
        print("called getDiskPartitionUUIDs function")
        
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
            print("Error retrieving disk partition UUIDs: \(error.localizedDescription)")
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
            print("Found \(testPath.description)")
            kInfoFiles.append(testPath.path)
        }
    }
}

// MARK: - KindleKeyManager
extension KindleKeyMacOS: KindleKeyManager {
    static func getDbFromFile(kinfoFile: String) -> OrderedDictionary<String, Data> {
        fatalError()
    }
    
    static func getUsername() -> Data {
        guard let username: String = ProcessInfo.processInfo.environment["USER"],
              let usernameData = username.data(using: .utf8) else {
            return .init()
        }
        
        Debug.print("Username:", usernameData.formattedForOutput)
        
        return usernameData
    }
    
    static func getKindleInfoFiles() -> OrderedSet<String> {
        var kInfoFiles: OrderedSet<String> = .init()
        
        guard let home: String = ProcessInfo.processInfo.environment["HOME"] else {
            return kInfoFiles
        }
        
        let pathsToCheck: OrderedSet<KindlePath> = KindlePath.getKindlePaths(homeDir: home)
        
        for testPath in pathsToCheck {
            checkAndAddFile(testPath: testPath, kInfoFiles: &kInfoFiles)
        }
        
        if kInfoFiles.isEmpty {
            print("No k4Mac kindle-info/rainier/kinf2011/kinf2018 files have been found.")
        }
        
        return kInfoFiles
    }
}
#endif
