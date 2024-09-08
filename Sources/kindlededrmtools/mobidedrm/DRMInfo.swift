//
//  DRMInfo.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation

struct DRMInfo {
  let key: Data
  let pid: String
}

extension DRMInfo: CustomStringConvertible {
  var description: String {
    return "(key: \(Util.formatData(data: key)), pid: \(pid))"
  }
}
