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
  
  var searchHistoryGroup: SearchHistoryGroup?
  
  var searchText: String
  var createDate: Date
  
  init(searchHistoryGroup: SearchHistoryGroup, searchText: String) {
    self.id = UUID()
    self.searchHistoryGroup = searchHistoryGroup
    self.searchText = searchText
    self.createDate = Date.now
    searchHistoryGroup.updateDate = Date.now
  }
}
