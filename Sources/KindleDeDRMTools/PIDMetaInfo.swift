//
//  PIDMetaInfo.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

struct PIDMetaInfo {
    let rec209: Data?
    let token: Data?
    
    init(rec209: Data? = nil, token: Data? = nil) {
        self.rec209 = rec209
        self.token = token
    }
}

// MARK: - CustomStringConvertible
extension PIDMetaInfo: CustomStringConvertible {
    var description: String {
        return "(rec209: \(rec209.formattedForOutput), token: \(token.formattedForOutput))"
    }
}

// MARK: - Convenience Initialisers
extension PIDMetaInfo {
    init(_ rec209: Data?, _ token: Data?) {
        self.init(rec209: rec209, token: token)
    }
}
