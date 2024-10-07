//
//  KindleDatabaseType.swift
//  kindlededrmtools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(macOS) || os(Windows)
import Foundation

enum KindleDatabaseType: String, Hashable {
#if os(macOS)
    case K4MACKINF2018 = "k4mac kinf2018"
    case K4MACKINF2011 = "k4mac kinf2011"
    case K4MACRAINIER = "k4mac rainier"
    case K4MACKINDLEINFO = "k4mac kindle-info"
#elseif os(Windows)
    case K4PC125KINF2018 = "K4PC 1.25+ kinf2018"
    case K4PC19KINF2011 = "K4PC 1.9+ kinf2011"
    case K4PC1618KINF = "K4PC 1.6-1.8 kinf"
    case K4PC15KINF = "K4PC 1.5 kinf"
    case K4PCKINDLEINFO = "K4PC kindle.info"
#endif
}

// MARK: - CustomStringConvertible
extension KindleDatabaseType: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}
#endif
