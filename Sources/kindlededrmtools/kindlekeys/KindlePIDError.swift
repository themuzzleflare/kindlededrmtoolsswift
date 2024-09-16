//
//  KindlePIDError.swift
//
//
//  Created by Paul Tavitian on 15/9/2024.
//

import Foundation

enum KindlePIDError {
    case stringFromDataFailed(data: Data)
    case dataFromStringFailed(string: String)
}

extension KindlePIDError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .stringFromDataFailed(data):
            return "Failed to convert data to string: \(Util.formatData(data))"
        case let .dataFromStringFailed(string):
            return "Failed to convert string to data: \(string)"
        }
    }
}
