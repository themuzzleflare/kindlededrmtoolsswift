//
//  Debug.swift
//
//
//  Created by Paul Tavitian on 8/9/2024.
//

import Foundation

public final actor Debug {
    private static var isEnabled: Bool = false
    
    private init() {}
    
    public static func enable() {
        isEnabled = true
    }
    
    public static func disable() {
        isEnabled = false
    }
    
    public static func setEnabled(enabled: Bool) {
        isEnabled = enabled
    }
    
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if isEnabled {
            Swift.print(items, separator: separator, terminator: terminator)
        }
    }
    
    static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if isEnabled {
            Swift.debugPrint(items, separator: separator, terminator: terminator)
        }
    }
}

// MARK: - Convenience Methods
extension Debug {
    public static func setEnabled(_ enabled: Bool) {
        setEnabled(enabled: enabled)
    }
}
