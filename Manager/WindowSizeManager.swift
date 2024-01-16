//
//  WindowSizeManager.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import Cocoa

class WindowSizeManager: NSObject {
    private static let widthKey = "WindowSizeWidth"
    private static let heightKey = "WindowSizeHeight"
    
    static func save(windowSize: NSSize) {
        UserDefaults.standard.set(windowSize.width, forKey: widthKey)
        UserDefaults.standard.set(windowSize.height, forKey: heightKey)
    }
    
    static func load() -> NSSize? {
        guard let width = UserDefaults.standard.value(forKey: widthKey) as? CGFloat,
              let height = UserDefaults.standard.value(forKey: heightKey) as? CGFloat else {
            return nil
        }
        
        return NSSize(width: width, height: height)
    }
}
