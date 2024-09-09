//
//  BookSections.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation

typealias BookSections = Array<BookSection>

extension BookSections {
    var description: String {
        return self.map { section in
            return section.description
        }.joined(separator: ",\n")
    }
}
