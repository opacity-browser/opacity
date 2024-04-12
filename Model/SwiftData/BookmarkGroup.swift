//
//  BookmarkGroup.swift
//  Opacity
//
//  Created by Falsy on 4/9/24.
//

import SwiftUI
import SwiftData

@Model
class BookmarkGroup {
  @Attribute(.unique) 
  var id: UUID
  var name: String
  var index: Int
  var depth: Int
  
  @Relationship
  var parent: BookmarkGroup?
  
  @Relationship(deleteRule: .cascade, inverse: \Bookmark.bookmarkGroup)
  var bookmarks: [Bookmark] = [Bookmark]()
  @Relationship(deleteRule: .cascade, inverse: \BookmarkGroup.parent)
  var bookmarkGroups: [BookmarkGroup] = [BookmarkGroup]()
  var isOpen: Bool = false
  
  var isBase: Bool = false
  
  init(index: Int, depth: Int, name: String = NSLocalizedString("New Folder", comment: ""), isBase: Bool = false) {
    self.id = UUID()
    self.name = name
    self.index = index
    self.isBase = isBase
    self.depth = depth
  }
}
