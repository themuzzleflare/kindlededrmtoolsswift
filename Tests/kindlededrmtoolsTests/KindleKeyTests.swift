//
//  KindleKeyTests.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 17/9/2024.
//

#if os(macOS)
import Foundation
import Testing
import OrderedCollections
@testable import kindlededrmtools

@Suite("KindleKey Tests")
struct KindleKeyTests {
    @Test("getMacAddressesMunged Test") func testGetMacAddressesMunged() {
        let mac1: Data = .init([97, 53, 97, 57, 99, 57, 98, 53, 97, 101, 97, 51])
        let mac2: Data = .init([101, 102, 51, 52, 57, 56, 49, 53, 100, 98, 100, 54])
        let mac3: Data = .init([101, 102, 51, 52, 57, 56, 49, 53, 100, 98, 100, 49])
        let mac4: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 53])
        let mac5: Data = .init([48, 49, 54, 97, 51, 99, 52, 49, 102, 51, 53, 52])
        let mac6: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 53])
        let mac7: Data = .init([57, 51, 97, 100, 56, 102, 49, 48, 55, 56, 101, 49])
        
        let expectedMacs: OrderedSet<Data> = [mac1, mac2, mac3, mac4, mac5, mac6, mac7]
        
        let result: OrderedSet<Data> = KindleKey.getMacAddressesMunged()
        
        for data in result {
            print(Util.formatData(data: data))
        }
        
        print()
        
        for data in expectedMacs {
            print(Util.formatData(data: data))
        }
        
        #expect(expectedMacs == result)
    }
}
#endif
