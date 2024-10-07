//
//  BookSections.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation

typealias BookSections = [BookSection]

extension BookSections {
    var description: String {
        return map(\.description).joined(separator: ",\n")
    }
}
