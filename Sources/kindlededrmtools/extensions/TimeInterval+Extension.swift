//
//  TimeInterval+Extension.swift
//
//
//  Created by Paul Tavitian on 10/9/2024.
//

import Foundation

extension TimeInterval {
    var oneDecimalPlace: String {
        return .init(format: "%.1f", self)
    }
    
    var twoDecimalPlaces: String {
        return .init(format: "%.2f", self)
    }
}
