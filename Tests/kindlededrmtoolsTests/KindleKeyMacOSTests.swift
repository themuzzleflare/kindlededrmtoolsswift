//
//  KindleKeyMacOSTests.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 17/9/2024.
//

#if os(macOS)
import Foundation
import Testing
import OrderedCollections
@testable import kindlededrmtools

@Suite("KindleKeyMacOS Tests")
struct KindleKeyMacOSTests {
    @Test("getMacAddressesMunged Test") func testGetMacAddressesMunged() {
        let mac1: Data = .init([97, 53, 97, 57, 99, 57, 98, 53, 97, 101, 97, 51])
        let mac2: Data = .init([101, 102, 51, 52, 57, 56, 49, 53, 100, 98, 100, 54])
        let mac3: Data = .init([101, 102, 51, 52, 57, 56, 49, 53, 100, 98, 100, 49])
        let mac4: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 53])
        let mac5: Data = .init([48, 49, 54, 97, 51, 99, 52, 49, 102, 51, 53, 52])
        let mac6: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 53])
        let mac7: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 49])
        
        let expectedMacs: OrderedSet<Data> = [mac1, mac2, mac3, mac4, mac5, mac6, mac7]
        
        let result: OrderedSet<Data> = KindleKeyMacOS.getMacAddressesMunged()
        
        #expect(expectedMacs == result)
    }
    
    @Test("getVolumeSerialNumbers Test") func testGetVolumeSerialNumbers() {
        let serialNum1: Data = .init([48, 98, 97, 48, 49, 101, 48, 49, 54, 48, 54, 53, 53, 97, 50, 97])
        
        let expectedSerialNums: OrderedSet<Data> = [serialNum1]
        
        let result: OrderedSet<Data> = KindleKeyMacOS.getVolumeSerialNumbers()
        
        #expect(expectedSerialNums == result)
    }
    
    @Test("getDiskPartitionNames Test") func testGetDiskPartitionNames() {
        let name1: Data = .init([100, 105, 115, 107, 51, 115, 49, 115, 49])
        let name2: Data = .init([100, 105, 115, 107, 51, 115, 54])
        let name3: Data = .init([100, 105, 115, 107, 51, 115, 50])
        let name4: Data = .init([100, 105, 115, 107, 51, 115, 52])
        let name5: Data = .init([100, 105, 115, 107, 49, 115, 50])
        let name6: Data = .init([100, 105, 115, 107, 49, 115, 49])
        let name7: Data = .init([100, 105, 115, 107, 49, 115, 51])
        let name8: Data = .init([100, 105, 115, 107, 51, 115, 53])
        let name9: Data = .init([100, 105, 115, 107, 55, 115, 49])
        let name10: Data = .init([100, 105, 115, 107, 53, 115, 49])
        let name11: Data = .init([100, 105, 115, 107, 57, 115, 49])
        
        let expectedNames: OrderedSet<Data> = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10, name11]
        
        let result: OrderedSet<Data> = KindleKeyMacOS.getDiskPartitionNames()
        
        #expect(expectedNames == result)
    }
    
    @Test("getDiskPartitionUUIDs Test") func testGetDiskPartitionUUIDs() {
        let uuid1: Data = .init([55, 48, 67, 68, 69, 69, 53, 65, 45, 65, 51, 57, 57, 45, 52, 67, 57, 57, 45, 66, 56, 51, 52, 45, 51, 50, 56, 50, 65, 66, 70, 52, 65, 52, 65, 56])
        let uuid2: Data = .init([68, 67, 49, 48, 48, 54, 68, 52, 45, 54, 56, 51, 65, 45, 52, 66, 51, 51, 45, 56, 69, 65, 51, 45, 51, 53, 67, 53, 67, 48, 54, 53, 57, 57, 50, 65])
        let uuid3: Data = .init([55, 65, 50, 53, 56, 65, 57, 51, 45, 48, 65, 48, 50, 45, 52, 66, 67, 55, 45, 65, 51, 66, 50, 45, 55, 51, 48, 49, 54, 67, 53, 49, 68, 70, 68, 56])
        let uuid4: Data = .init([55, 65, 50, 53, 56, 65, 57, 51, 45, 48, 65, 48, 50, 45, 52, 66, 67, 55, 45, 65, 51, 66, 50, 45, 55, 51, 48, 49, 54, 67, 53, 49, 68, 70, 68, 56])
        let uuid5: Data = .init([65, 57, 66, 69, 52, 49, 56, 69, 45, 48, 55, 65, 69, 45, 52, 65, 48, 48, 45, 65, 67, 57, 53, 45, 52, 70, 70, 66, 56, 54, 57, 65, 68, 56, 49, 49])
        let uuid6: Data = .init([70, 65, 55, 70, 48, 69, 53, 53, 45, 69, 55, 68, 50, 45, 52, 57, 69, 67, 45, 65, 67, 57, 54, 45, 68, 69, 68, 55, 66, 66, 68, 49, 51, 70, 68, 52])
        let uuid7: Data = .init([48, 49, 50, 70, 56, 65, 53, 68, 45, 50, 48, 67, 48, 45, 52, 55, 48, 65, 45, 56, 65, 54, 66, 45, 67, 65, 56, 53, 68, 50, 68, 49, 65, 54, 66, 48])
        let uuid8: Data = .init([53, 67, 53, 69, 56, 57, 48, 50, 45, 66, 50, 57, 53, 45, 52, 66, 53, 65, 45, 66, 69, 65, 57, 45, 54, 67, 48, 69, 68, 57, 57, 56, 50, 70, 66, 67])
        let uuid9: Data = .init([56, 48, 65, 55, 48, 70, 51, 70, 45, 67, 53, 56, 53, 45, 52, 70, 70, 53, 45, 65, 52, 65, 51, 45, 54, 49, 68, 50, 68, 57, 70, 50, 56, 65, 54, 70])
        let uuid10: Data = .init([52, 57, 55, 65, 55, 51, 48, 51, 45, 70, 57, 68, 52, 45, 52, 52, 67, 67, 45, 66, 51, 65, 69, 45, 69, 69, 56, 67, 68, 66, 65, 70, 69, 67, 53, 69])
        let uuid11: Data = .init([52, 57, 55, 65, 55, 51, 48, 51, 45, 70, 57, 68, 52, 45, 52, 52, 67, 67, 45, 66, 51, 65, 69, 45, 69, 69, 56, 67, 68, 66, 65, 70, 69, 67, 53, 69])
        let uuid12: Data = .init([66, 65, 57, 57, 68, 57, 55, 68, 45, 50, 50, 70, 65, 45, 52, 68, 48, 54, 45, 57, 70, 70, 68, 45, 65, 55, 68, 66, 55, 48, 51, 50, 49, 55, 48, 48])
        let uuid13: Data = .init([66, 66, 48, 66, 66, 68, 52, 69, 45, 56, 55, 51, 68, 45, 52, 66, 51, 67, 45, 65, 48, 56, 68, 45, 54, 54, 65, 52, 69, 57, 52, 57, 48, 70, 49, 52])
        let uuid14: Data = .init([50, 48, 55, 70, 56, 69, 65, 52, 45, 65, 49, 51, 70, 45, 52, 55, 55, 53, 45, 66, 70, 48, 56, 45, 52, 51, 55, 57, 51, 48, 66, 55, 50, 56, 56, 65])
        let uuid15: Data = .init([53, 51, 65, 50, 48, 54, 70, 56, 45, 52, 67, 56, 49, 45, 52, 67, 55, 68, 45, 65, 51, 69, 52, 45, 55, 50, 57, 65, 52, 67, 70, 55, 67, 56, 65, 69])
        let uuid16: Data = .init([50, 48, 54, 49, 53, 69, 68, 56, 45, 67, 56, 56, 69, 45, 52, 65, 51, 49, 45, 56, 52, 69, 70, 45, 66, 56, 66, 69, 50, 53, 68, 48, 53, 50, 57, 49])
        let uuid17: Data = .init([56, 70, 65, 68, 54, 54, 48, 57, 45, 69, 70, 68, 52, 45, 52, 53, 55, 68, 45, 56, 54, 49, 48, 45, 49, 52, 56, 50, 69, 53, 67, 54, 52, 66, 50, 67])
        let uuid18: Data = .init([67, 54, 69, 51, 57, 49, 52, 48, 45, 69, 66, 67, 48, 45, 52, 55, 65, 48, 45, 56, 51, 65, 65, 45, 50, 70, 55, 68, 48, 55, 69, 51, 48, 68, 54, 55])
        let uuid19: Data = .init([66, 65, 65, 48, 65, 68, 53, 67, 45, 52, 70, 53, 48, 45, 52, 56, 48, 69, 45, 65, 51, 66, 55, 45, 55, 66, 67, 55, 69, 51, 65, 66, 57, 53, 65, 68])
        let uuid20: Data = .init([67, 66, 70, 68, 67, 68, 65, 49, 45, 52, 69, 67, 67, 45, 52, 54, 65, 66, 45, 56, 65, 66, 67, 45, 57, 66, 69, 70, 49, 66, 69, 56, 52, 50, 70, 49])
        let uuid21: Data = .init([67, 66, 70, 68, 67, 68, 65, 49, 45, 52, 69, 67, 67, 45, 52, 54, 65, 66, 45, 56, 65, 66, 67, 45, 57, 66, 69, 70, 49, 66, 69, 56, 52, 50, 70, 49])
        let uuid22: Data = .init([53, 70, 65, 48, 54, 51, 50, 56, 45, 49, 70, 50, 65, 45, 52, 55, 54, 51, 45, 57, 51, 50, 51, 45, 67, 52, 52, 52, 57, 66, 53, 49, 51, 55, 57, 68])
        let uuid23: Data = .init([69, 50, 65, 69, 56, 51, 51, 67, 45, 67, 52, 70, 70, 45, 52, 50, 54, 56, 45, 65, 55, 66, 54, 45, 54, 67, 50, 50, 67, 55, 53, 54, 48, 54, 50, 66])
        
        let expectedUUIDs: OrderedSet<Data> = [uuid1, uuid2, uuid3, uuid4, uuid5, uuid6, uuid7, uuid8, uuid9, uuid10, uuid11, uuid12, uuid13, uuid14, uuid15, uuid16, uuid17, uuid18, uuid19, uuid20, uuid21, uuid22, uuid23]
        
        let result: OrderedSet<Data> = KindleKeyMacOS.getDiskPartitionUUIDs()
        
        #expect(expectedUUIDs == result)
    }
    
    @Test("getUsername Test") func testGetUsername() {
        let expected: Data = .init([112, 97, 117, 108, 116, 97, 118, 105, 116, 105, 97, 110])
        
        let result: Data = KindleKeyMacOS.getUsername()
        
        #expect(expected == result)
    }
}
#endif
