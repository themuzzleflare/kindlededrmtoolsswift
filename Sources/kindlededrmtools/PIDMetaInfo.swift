//
//  PIDMetaInfo.swift
//
//
//  Created by Paul Tavitian on 6/9/2024.
//

import Foundation

struct PIDMetaInfo {
  let rec209: Data
  let token: Data
}

extension PIDMetaInfo: CustomStringConvertible {
  var description: String {
    return "(rec209: \(Util.formatData(data: rec209)), token: \(Util.formatData(data: token)))"
  }
}
