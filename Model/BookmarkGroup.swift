//
//  BookmarkGroup.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

@Model
class BookmarkGroup: Identifiable {
  @Attribute(.unique) 
  var id: UUID = UUID()
  
  var name: String = "New Folder"
  
  var parentGroupId: UUID? = nil
  
  @Relationship(deleteRule: .cascade)
  var groups: [BookmarkGroup] = []
  
  @Relationship(deleteRule: .cascade)
  var bookmarks: [Bookmark] = []
  
  init(parentGroupId: UUID? = nil) {
    self.parentGroupId = parentGroupId
  }
}
