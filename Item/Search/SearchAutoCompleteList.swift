//
//  SearchAutoCompleteList.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI

struct SearchAutoCompleteList: View {
  var searchHistoryGroup: [SearchHistoryGroup]
  
  init(searchHistoryGroup: [SearchHistoryGroup]) {
    self.searchHistoryGroup = searchHistoryGroup.sorted {
      $0.searchHistories!.count > $1.searchHistories!.count
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(searchHistoryGroup) { sh in
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Text(sh.searchText)
            Text("-")
            Text("\(sh.searchHistories!.count)")
          }
        }
      }
    }
  }
}
