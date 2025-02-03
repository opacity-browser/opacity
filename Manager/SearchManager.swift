//
//  SearchManager.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

class SearchManager {
  @MainActor static func findSearchHistoryGroup(_ keyword: String) -> [SearchHistoryGroup]? {
    let lowercaseKeyword = keyword.lowercased()
    var descriptor = FetchDescriptor<SearchHistoryGroup>(
      predicate: #Predicate<SearchHistoryGroup> { search in
        search.searchText.starts(with: lowercaseKeyword)
      },
      sortBy: [SortDescriptor(\SearchHistoryGroup.updateDate, order: .reverse)]
    )
    descriptor.fetchLimit = 5
    
    do {
      let searchHistoryGroupList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return searchHistoryGroupList
    } catch {
      print("ModelContainerError findSearchHistoryGroup")
      print(error)
    }
    
    return nil
  }
  
  @MainActor static func getSearchHistoryGroup(_ keyword: String) -> SearchHistoryGroup? {
    let descriptor = FetchDescriptor<SearchHistoryGroup>(
      predicate: #Predicate { $0.searchText == keyword }
    )
    do {
      if let searchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        return searchHistoryGroup
      }
    } catch {
      print("ModelContainerError getSearchHistoryGroup")
    }
    return nil
  }
  
  @MainActor static func addSearchHistory(_ keyword: String) {
    let uppLowLetters = StringURL.checkURL(url: keyword) ? keyword.lowercased() : keyword
    if let searchGroup = self.getSearchHistoryGroup(uppLowLetters) {
      let newSearchHistory = SearchHistory(searchHistoryGroup: searchGroup)
      searchGroup.searchHistories.append(newSearchHistory)
    } else {
      do {
        let newSearchHistoryGroup = SearchHistoryGroup(searchText: uppLowLetters)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newSearchHistoryGroup)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        self.addSearchHistory(uppLowLetters)
      } catch {
        print("ModelContainerError addSearchHistory")
      }
    }
  }
  
  @MainActor static func deleteAllSearchHistory() {
    let descriptor = FetchDescriptor<SearchHistory>()
    let descriptorGroup = FetchDescriptor<SearchHistoryGroup>()
    do {
      let allSearchHistory = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      let allSearchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptorGroup)
      for searchHistory in allSearchHistory {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(searchHistory)
      }
      for shGroup in allSearchHistoryGroup {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(shGroup)
      }
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
       print("ModelContainerError deleteAllSearchHistory")
     }
  }
  
  @MainActor static func deleteSearchHistoryGroup(_ target: SearchHistoryGroup) {
    for searchHistory in target.searchHistories {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(searchHistory)
    }
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("ModelContainerError deleteSearchHistoryGroup")
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
      print("ModelContainerError deleteSearchHistoryById")
    }
  }
  
  @MainActor static func deleteSearchHistoryGroupById(_ id: UUID) {
    let descriptor = FetchDescriptor<SearchHistoryGroup>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let emptySearchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        if emptySearchHistoryGroup.searchHistories.isEmpty {
          self.deleteSearchHistoryGroup(emptySearchHistoryGroup)
        }
      }
      
      
    } catch {
      print("ModelContainerError deleteSearchHistoryGroupById")
    }
  }
}
