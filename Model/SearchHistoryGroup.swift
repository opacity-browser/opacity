//
//  SearchHistoryCount.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

@Model
class SearchHistoryGroup: Identifiable {
  @Attribute(.unique)
  var id: UUID
  
  @Attribute(.unique)
  var searchText: String
  
  @Relationship(deleteRule: .cascade)
  var searchHistories: [SearchHistory]? = [SearchHistory]()
  
  init(searchText: String) {
    self.id = UUID()
    self.searchText = searchText
  }
}
