//
//  SearchAutoComplete.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchAutoComplete: View {
  @Environment(\.modelContext) var modelContext
  @Query var searchHistoryGroup: [SearchHistoryGroup]
//  @Query var searchHistory: [SearchHistory]
  
  @ObservedObject var tab: Tab
//  var searchHistoryGroup: [SearchHistoryGroup]
  
  init(tab: Tab, keyword: String) {
    self.tab = tab
    self._searchHistoryGroup = Query(filter: #Predicate<SearchHistoryGroup> {
      $0.searchText.contains(keyword)
    }, sort: \SearchHistoryGroup.updateDate, order: .reverse)
    
//    let filterSearchHistories = searchHistoryGroup.filter {
//      $0.searchText.contains(tab.inputURL)
//    }
//    let sortSearchHistories = filterSearchHistories.sorted {
//      $0.searchHistories!.count < $1.searchHistories!.count
//    }
//    self.searchHistoryGroup = sortSearchHistories
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if searchHistoryGroup.count > 0 {
        SearchAutoCompleteList(searchHistoryGroup: searchHistoryGroup)
      } else {
        Text("검색 기록이 없습니다.")
          .padding(.vertical, 10)
      }
    }
    .padding(.vertical, 5)
  }
}
