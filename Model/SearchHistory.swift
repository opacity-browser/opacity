//
//  SearchHistory.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

@Model
class SearchHistory: Identifiable  {
  @Attribute(.unique)
  var id: UUID
  
  @Relationship(inverse: \SearchHistoryGroup.searchHistories)
  var searchTextGroup: SearchHistoryGroup
  
  var searchText: String
  var createDate: Date
  var count: UInt?
  
  init(searchTextGroup: SearchHistoryGroup, searchText: String) {
    self.id = UUID()
    self.searchTextGroup = searchTextGroup
    self.searchText = searchText
    self.createDate = Date.now
  }
}
