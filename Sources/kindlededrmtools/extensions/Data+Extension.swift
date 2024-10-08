//
//  Data+Extension.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

import Foundation

extension Data {
    var formattedForOutput: String {
        return Util.formatData(data: self)
    }
    
    var hexString: String {
        return Util.dataToHexString(data: self)
    }
}

extension Data? {
    var formattedForOutput: String {
        return Util.formatData(data: self)
    }
    
    var hexString: String {
        return Util.dataToHexString(data: self)
    }
}
