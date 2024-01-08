//
//  BookmarkGroup.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftData

@Model
final class BookmarkGroup {
  var name: String
  var parent: BookmarkGroup?
  var bookmarks: [Bookmark] = []
    
  init(name: String = "New Group") {
    self.name = name
  }
}
