//
//  IORegStorageDriveClasses.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(macOS)
import Foundation

enum IORegStorageDriveClasses: String, CaseIterable {
    case appleAHCIDiskDriver = "AppleAHCIDiskDriver"
    case appleANS3NVMeController = "AppleANS3NVMeController"
}
#endif
