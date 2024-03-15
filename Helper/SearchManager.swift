//
//  SearchManager.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

class SearchManager {
  @MainActor static func getSearchHistoryGroup(_ keyword: String) -> SearchHistoryGroup? {
    let descriptor = FetchDescriptor<SearchHistoryGroup>(
      predicate: #Predicate { $0.searchText == keyword }
    )
    do {
      if let searchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        return searchHistoryGroup
      }
    } catch {
      print("get search history group error")
    }
    return nil
  }
  
  @MainActor static func addSearchHistory(_ keyword: String) {
    if let searchGroup = self.getSearchHistoryGroup(keyword) {
      do {
        let newSearchHistory = SearchHistory(searchTextGroup: searchGroup, searchText: keyword)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistory)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      } catch {
        print("add search history error")
      }
    } else {
      do {
        let newSearchHistoryGroup = SearchHistoryGroup(searchText: keyword)
        let newSearchHistory = SearchHistory(searchTextGroup: newSearchHistoryGroup, searchText: keyword)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistoryGroup)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistory)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      } catch {
        print("add search history, search history group error")
      }
    }
  }
  
  
}
