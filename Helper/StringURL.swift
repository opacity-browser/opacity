//
//  StringURL.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import Foundation

class StringURL {
    static func shortURL(url urlString: String) -> String {
        let checkLastSlash = self.removeLastSlash(url: urlString)
        let pattern = "^(http(s)?\\:\\/\\/(www.)?)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: checkLastSlash.utf16.count)
        
        return regex.stringByReplacingMatches(in: checkLastSlash, options: [], range: range, withTemplate: "")
    }
    
    static func removeLastSlash(url urlString: String) -> String {
        let containsQuestionMark = urlString.contains("?")
        let containsHash = urlString.contains("#")
        let isLastSlash = urlString.hasSuffix("/")
        var returnUrlString = urlString
        
        if isLastSlash && !containsQuestionMark && !containsHash {
            returnUrlString.removeLast()
        }
        
        return returnUrlString
    }
}
