//
//  IORegStorageDriveClasses.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(macOS)
enum IORegStorageDriveClasses: String, CaseIterable {
    case appleAHCIDiskDriver = "AppleAHCIDiskDriver"
    case appleANS3NVMeController = "AppleANS3NVMeController"
}

// MARK: - CustomStringConvertible
extension IORegStorageDriveClasses: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}
#endif
