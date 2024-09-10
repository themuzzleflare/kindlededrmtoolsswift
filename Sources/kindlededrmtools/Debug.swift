//
//  Debug.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation

public enum Debug {
    private static var isEnabled: Bool = false
    
    public static func enable() {
        isEnabled = true
    }
    
    public static func disable() {
        isEnabled = false
    }
    
    public static func setEnabled(enabled: Bool) {
        isEnabled = enabled
    }
    
    public static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if isEnabled {
            Swift.print(items, separator: separator, terminator: terminator)
        }
    }
    
    public static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if isEnabled {
            Swift.debugPrint(items, separator: separator, terminator: terminator)
        }
    }
}
