//
//  PC1Error.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

enum PC1Error {
  case badKeyLength(length: Int)
}

extension PC1Error: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .badKeyLength(let length):
      return "PC1: Bad key length: " + length.description + ". Must be 16."
    }
  }
}
