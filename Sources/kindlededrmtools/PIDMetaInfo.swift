//
//  PIDMetaInfo.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

public struct PIDMetaInfo {
    let rec209: Data?
    let token: Data?
    
    init(rec209: Data? = nil, token: Data? = nil) {
        self.rec209 = rec209
        self.token = token
    }
}

// MARK: - Convenience Initialisers/Methods
extension PIDMetaInfo {
    init(_ rec209: Data?, _ token: Data?) {
        self.init(rec209: rec209, token: token)
    }
}

// MARK: - CustomStringConvertible
extension PIDMetaInfo: CustomStringConvertible {
    public var description: String {
        return "(rec209: \(Util.formatData(data: rec209)), token: \(Util.formatData(data: token)))"
    }
}
