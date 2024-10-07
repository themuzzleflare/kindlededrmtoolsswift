//
//  String+Extension.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

import Foundation

extension String {
    var hexToData: Data? {
        return Util.hexStringToData(hexString: self)
    }
}

extension String? {
    var hexToData: Data? {
        return Util.hexStringToData(hexString: self)
    }
}
