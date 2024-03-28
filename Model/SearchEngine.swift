//
//  SearchEngine.swift
//  Opacity
//
//  Created by Falsy on 1/21/24.
//

import SwiftUI

final class SearchEngine: Codable {
  var name: String
  var searchUrlString: String
  var favicon: String
  
  init(name: String, searchUrlString: String, favicon: String) {
    self.name = name
    self.searchUrlString = searchUrlString
    self.favicon = favicon
  }
}
