//
//  File.swift
//  
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

enum MobiBookError {
  case urlCreationFiled
  case invalidFileFormat
}

extension MobiBookError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .urlCreationFiled:
      return "Failed to create URL representing input file path."
    case .invalidFileFormat:
      return "Invalid File Format"
    }
  }
}
