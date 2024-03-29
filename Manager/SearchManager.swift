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
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("delete search history error")
    }
  }
  
  @MainActor static func deleteSearchHistoryGroup(_ target: SearchHistoryGroup) {
    if let searchHistories = target.searchHistories {
      for searchHistory in searchHistories {
        self.deleteSearchHistory(searchHistory)
      }
    }
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
       print("delete search history group error")
     }
  }
  
  @MainActor static func deleteSearchHistoryById(_ id: UUID) {
    let descriptor = FetchDescriptor<SearchHistory>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        let cacheGroupId = target.searchHistoryGroup?.id
        AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        if let groupId = cacheGroupId {
          self.deleteSearchHistoryGroupById(groupId)
        }
      }
    } catch {
      print("delete search history error")
    }
  }
  
  @MainActor static func deleteSearchHistoryGroupById(_ id: UUID) {
    let descriptor = FetchDescriptor<SearchHistoryGroup>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let emptySearchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        if emptySearchHistoryGroup.searchHistories!.count == 0 {
          self.deleteSearchHistoryGroup(emptySearchHistoryGroup)
        }
      }
    } catch {
      print("get empty search history group error")
    }
  }
}
