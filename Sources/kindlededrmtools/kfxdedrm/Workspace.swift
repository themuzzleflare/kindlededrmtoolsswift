//
//  Workspace.swift
//
//
//  Created by Paul Tavitian on 12/9/2024.
//

import Foundation

final class Workspace {
    var work: [Int]
    
    init(initialList: [Int]) {
        work = initialList
    }
    
    convenience init(_ initialList: [Int]) {
        self.init(initialList: initialList)
    }
    
    convenience init(initialList: Int...) {
        self.init(initialList: initialList)
    }
    
    convenience init(_ initialList: Int...) {
        self.init(initialList: initialList)
    }
    
    func shuffle(shufList: [Int]) {
        var rt: [Int] = .init()
        
        for i in shufList {
            rt.append(work[i])
        }
        
        work = rt
    }
    
    func shuffle(_ shufList: [Int]) {
        shuffle(shufList: shufList)
    }
    
    func shuffle(shufList: Int...) {
        shuffle(shufList: shufList)
    }
    
    func shuffle(_ shufList: Int...) {
        return shuffle(shufList: shufList)
    }
    
    func sbox(table: [Int], matrix: [Int], skpList: [Int] = .init()) {
        var offset: Int = 0
        
        var nwork: [Int] = work
        
        var wo: Int = 0
        var toff: Int = 0
        
        while offset < 0x6000 {
            let uv5: Int = table[toff + nwork[wo]]
            let uv1: Int = table[toff + nwork[wo + 1] + 0x100]
            let uv2: Int = table[toff + nwork[wo + 2] + 0x200]
            let uv3: Int = table[toff + nwork[wo + 3] + 0x300]
            var moff: Int = 0;
            
            var nib1: Int = 0;
            var nib2: Int = 0;
            var nib3: Int = 0;
            var nib4: Int = 0;
            
            if skpList.contains(0) {
                moff += 0x400;
            } else {
                nib1 = matrix[moff + offset + ((uv1 >> 0x1c) & 0xf) | ((uv5 >> 0x18) & 0xf0)];
                moff += 0x100;
                nib2 = matrix[moff + offset + ((uv3 >> 0x1c) & 0xf) | ((uv2 >> 0x18) & 0xf0)];
                moff += 0x100;
                nib3 = matrix[moff + offset + ((uv1 >> 0x18) & 0xf) | ((uv5 >> 0x14) & 0xf0)];
                moff += 0x100;
                nib4 = matrix[moff + offset + ((uv3 >> 0x18) & 0xf) | ((uv2 >> 0x14) & 0xf0)];
                moff += 0x100;
            }
            
            var rnib1: Int = matrix[moff + offset + nib1 * 0x10 + nib2];
            moff += 0x100;
            var rnib2: Int = matrix[moff + offset + nib3 * 0x10 + nib4];
            moff += 0x100;
            nwork[wo] = rnib1 * 0x10 + rnib2;
            
            if skpList.contains(1) {
                moff += 0x400;
            } else {
                nib1 = matrix[moff + offset + ((uv1 >> 0x14) & 0xf) | ((uv5 >> 0x10) & 0xf0)];
                moff += 0x100;
                nib2 = matrix[moff + offset + ((uv3 >> 0x14) & 0xf) | ((uv2 >> 0x10) & 0xf0)];
                moff += 0x100;
                nib3 = matrix[moff + offset + ((uv1 >> 0x10) & 0xf) | ((uv5 >> 0xc) & 0xf0)];
                moff += 0x100;
                nib4 = matrix[moff + offset + ((uv3 >> 0x10) & 0xf) | ((uv2 >> 0xc) & 0xf0)];
                moff += 0x100;
            }
            
            rnib1 = matrix[moff + offset + nib1 * 0x10 + nib2];
            moff += 0x100;
            rnib2 = matrix[moff + offset + nib3 * 0x10 + nib4];
            moff += 0x100;
            nwork[wo + 1] = rnib1 * 0x10 + rnib2;
            
            if skpList.contains(2) {
                moff += 0x400;
            } else {
                nib1 = matrix[moff + offset + ((uv1 >> 0xc) & 0xf) | ((uv5 >> 0x8) & 0xf0)];
                moff += 0x100;
                nib2 = matrix[moff + offset + ((uv3 >> 0xc) & 0xf) | ((uv2 >> 0x8) & 0xf0)];
                moff += 0x100;
                nib3 = matrix[moff + offset + ((uv1 >> 0x8) & 0xf) | ((uv5 >> 0x4) & 0xf0)];
                moff += 0x100;
                nib4 = matrix[moff + offset + ((uv3 >> 0x8) & 0xf) | ((uv2 >> 0x4) & 0xf0)];
                moff += 0x100;
            }
            
            rnib1 = matrix[moff + offset + nib1 * 0x10 + nib2];
            moff += 0x100;
            rnib2 = matrix[moff + offset + nib3 * 0x10 + nib4];
            moff += 0x100;
            nwork[wo + 2] = rnib1 * 0x10 + rnib2
            
            if skpList.contains(3) {
                moff += 0x400;
            } else {
                nib1 = matrix[moff + offset + ((uv1 >> 0x4) & 0xf) | (uv5 & 0xf0)];
                moff += 0x100;
                nib2 = matrix[moff + offset + ((uv3 >> 0x4) & 0xf) | (uv2 & 0xf0)];
                moff += 0x100;
                nib3 = matrix[moff + offset + (uv1 & 0xf) | ((uv5 << 4) & 0xf0)];
                moff += 0x100;
                nib4 = matrix[moff + offset + (uv3 & 0xf) | ((uv2 << 4) & 0xf0)];
                moff += 0x100;
            }
            
            rnib1 = matrix[moff + offset + nib1 * 0x10 + nib2];
            moff += 0x100;
            rnib2 = matrix[moff + offset + nib3 * 0x10 + nib4];
            moff += 0x100;
            nwork[wo + 3] = rnib1 * 0x10 + rnib2
            
            offset += 0x1800;
            wo += 4;
            toff += 0x400;
        }
        
        work = nwork;
    }
    
    func sbox(_ table: [Int], _ matrix: [Int], _ skpList: [Int] = .init()) {
        sbox(table: table, matrix: matrix, skpList: skpList)
    }
    
    func sbox(table: [Int], matrix: [Int], skpList: Int...) {
        sbox(table: table, matrix: matrix, skpList: skpList)
    }
    
    func sbox(_ table: [Int], _ matrix: [Int], _ skpList: Int...) {
        sbox(table: table, matrix: matrix, skpList: skpList)
    }
    
    func exlookup(ltable: [Int]) {
        var lookoffs: Int = 0
        
        for a in 0..<work.count {
            work[a] = ltable[work[a] + lookoffs]
            lookoffs += 0x100;
        }
    }
    
    func exlookup(_ ltable: [Int]) {
        exlookup(ltable: ltable)
    }
    
    func mask(chunk: Data) -> [Int] {
        var out: [Int] = .init()
        
        for a in 0..<chunk.count {
            work[a] = work[a] ^ .init(chunk[a])
            out.append(work[a])
        }
        
        return out
    }
    
    func mask(_ chunk: Data) -> [Int] {
        return mask(chunk: chunk)
    }
    
    func mask(chunk: Data) -> Data {
        var out: Data = .init()
        
        for a in 0..<chunk.count {
            work[a] = work[a] ^ .init(chunk[a])
            out.append(.init(work[a]))
        }
        
        return out
    }
    
    func mask(_ chunk: Data) -> Data {
        return mask(chunk: chunk)
    }
}
