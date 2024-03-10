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
  var id: UUID
  
  var title: String
  
  @Relationship(inverse: \Bookmark.children)
  var parent: Bookmark? = nil

  var url: String? = nil
  var favicon: Data? = nil
  
  @Relationship(deleteRule: .cascade)
  var children: [Bookmark]? = [Bookmark]()
  
  @Attribute(.ephemeral)
  var isOpen: Bool = false
 
  init(title: String = "New Folder", parent: Bookmark? = nil, url: String? = nil, favicon: Data? = nil) {
    self.id = UUID()
    self.title = title
    self.parent = parent
    self.url = url
    self.favicon = favicon
  }
}
