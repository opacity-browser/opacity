//
//  Bookmark.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftData

@Model
final class Bookmark {
  var name: String
//  var tab: Tab?
  
  init(name: String = "New Bookmark") {
    self.name = name
  }
}
