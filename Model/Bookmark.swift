//
//  Bookmark.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

@Model
class Bookmark: Identifiable {
  @Attribute(.unique)
  var id: UUID = UUID()
  
  var title: String
  var url: String
  var favicon: Data? = nil
  
  @Relationship(inverse: \BookmarkGroup.id)
  var groupId: UUID?
 
  init(title: String, url: String, favicon: Data) {
    self.title = title
    self.url = url
    self.favicon = favicon
  }
}
