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
    let uppLowLetters = StringURL.checkURL(url: keyword) ? keyword.lowercased() : keyword
    if let searchGroup = self.getSearchHistoryGroup(uppLowLetters) {
      let newSearchHistory = SearchHistory(searchHistoryGroup: searchGroup)
      searchGroup.searchHistories?.append(newSearchHistory)
    } else {
      do {
        let newSearchHistoryGroup = SearchHistoryGroup(searchText: uppLowLetters)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistoryGroup)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        self.addSearchHistory(uppLowLetters)
      } catch {
        print("add search history, search history group error")
      }
    }
  }
  
  @MainActor static func deleteSearchHistory(_ target: SearchHistory) {
    AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
  }
  
  @MainActor static func deleteSearchHistoryGroup(_ target: SearchHistoryGroup) {
    if let searchHistories = target.searchHistories {
      for searchHistory in searchHistories {
        self.deleteSearchHistory(searchHistory)
      }
    }
    AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
  }
}
