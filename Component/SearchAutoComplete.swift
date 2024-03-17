//
//  SearchAutoComplete.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchAutoComplete: View {
  @ObservedObject var tab: Tab
  var autoCompleteList: [SearchHistoryGroup]
  
//  @Environment(\.modelContext) var modelContext
//  @Query var searchHistoryGroups: [SearchHistoryGroup]
  
//  init(tab: Tab, searchHistoryGroups: [SearchHistoryGroup]) {
//    self.tab = tab
//    let lowercaseKeyword = tab.inputURL.lowercased()
//    self._searchHistoryGroups = Query(filter: #Predicate<SearchHistoryGroup> {
//      $0.searchText.localizedStandardContains(lowercaseKeyword)
//    }, sort: \SearchHistoryGroup.updateDate, order: .reverse)
//  }
  
  var body: some View {
    VStack(spacing: 0) {
      if autoCompleteList.count > 0 {
        ForEach(autoCompleteList) { autoCompleteList in
          SearchAutoCompleteItem(searchHistoryGroup: autoCompleteList)
        }
      } else {
        Text("검색 기록이 없습니다.")
          .padding(.vertical, 10)
      }
    }
    .padding(.top, 4)
    .padding(.bottom, 5)
  }
}
