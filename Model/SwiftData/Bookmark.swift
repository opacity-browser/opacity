//
//  Bookmark.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

@Model
class Bookmark {
  @Attribute(.unique) 
  var id: UUID
  @Attribute(.unique) 
  var url: String
  var title: String
  var index: Int
  var favicon: Data? = nil

  @Relationship 
  var bookmarkGroup: BookmarkGroup?
  
  init(index: Int, title: String, url: String, favicon: Data? = nil) {
    self.id = UUID()
    self.title = title
    self.index = index
    self.url = url
    self.favicon = favicon
  }
}
