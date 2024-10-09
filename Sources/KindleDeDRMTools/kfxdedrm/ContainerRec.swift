//
//  ContainerRec.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

struct ContainerRec {
    let nextPos: Int
    let tid: Int
    let remaining: Int
    
    init(nextPos: Int, tid: Int, remaining: Int) {
        self.nextPos = nextPos
        self.tid = tid
        self.remaining = remaining
    }
}

// MARK: - Convenience Initialisers
extension ContainerRec {
    init(_ nextPos: Int, _ tid: Int, _ remaining: Int) {
        self.init(nextPos: nextPos, tid: tid, remaining: remaining)
    }
}
