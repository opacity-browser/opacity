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
      do {
        let newSearchHistory = SearchHistory(searchTextGroup: searchGroup, searchText: uppLowLetters)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistory)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      } catch {
        print("add search history error")
      }
    } else {
      do {
        let newSearchHistoryGroup = SearchHistoryGroup(searchText: uppLowLetters)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistoryGroup)
        let newSearchHistory = SearchHistory(searchTextGroup: newSearchHistoryGroup, searchText: uppLowLetters)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistory)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      } catch {
        print("add search history, search history group error")
      }
    }
  }
  
  
}
