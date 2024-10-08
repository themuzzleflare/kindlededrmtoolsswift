//
//  SystemProfilerStorageDriveDataTypes.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(macOS)
enum SystemProfilerStorageDriveDataTypes: String, CaseIterable {
    case spSerialATADataType = "SPSerialATADataType"
    case spNVMeDataType = "SPNVMeDataType"
}
#endif
