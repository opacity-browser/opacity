//
//  VisitManager.swift
//  Opacity
//
//  Created by Falsy on 3/25/24.
//

import SwiftUI
import SwiftData

class VisitManager {
  @MainActor static func getVisitHistoryGroup(_ url: String) -> VisitHistoryGroup? {
    let descriptor = FetchDescriptor<VisitHistoryGroup>(
      predicate: #Predicate { $0.url == url }
    )
    do {
      if let visitHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        return visitHistoryGroup
      }
    } catch {
      print("ModelContainerError getVisitHistoryGroup")
    }
    return nil
  }
  
  @MainActor static func addVisitHistory(url: String, title: String? = nil, faviconData: Data? = nil) {
    if let visitGroup = self.getVisitHistoryGroup(url) {
      let currentDate = Date()
      if visitGroup.visitHistories.count == 0 || currentDate.timeIntervalSince(visitGroup.updateDate) > 60 {
        let newVisitHistory = VisitHistory(visitHistoryGroup: visitGroup)
        visitGroup.visitHistories.append(newVisitHistory)
      } else {
        if let title = title, title != "", (visitGroup.title == nil || visitGroup.title == "") {
          visitGroup.title = title
        }
      }
    } else {
      do {
        let newVisitHistoryGroup = VisitHistoryGroup(url: url, title: title, faviconData: faviconData)
        AppDelegate.shared.opacityModelContainer.mainContext.insert(newVisitHistoryGroup)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        self.addVisitHistory(url: url)
      } catch {
        print("ModelContainerError addVisitHistory")
      }
    }
  }
  
  @MainActor static func deleteVisitHistory(_ target: VisitHistory) {
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("ModelContainerError deleteVisitHistory")
    }
  }
  
  @MainActor static func deleteVisitHistoryGroup(_ target: VisitHistoryGroup) {
//    if let visitHistories = target.visitHistories {
      for visitHistory in target.visitHistories {
        self.deleteVisitHistory(visitHistory)
      }
//    }
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("ModelContainerError deleteVisitHistoryGroup")
     }
  }
  
  @MainActor static func deleteVisitHistoryById(_ id: UUID) {
    let descriptor = FetchDescriptor<VisitHistory>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        let cacheGroupId = target.visitHistoryGroup?.id
        AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        if let groupId = cacheGroupId {
          self.deleteVisitHistoryGroupById(groupId)
        }
      }
    } catch {
      print("ModelContainerError deleteVisitHistoryById")
    }
  }
  
  @MainActor static func deleteVisitHistoryGroupById(_ id: UUID) {
    let descriptor = FetchDescriptor<VisitHistoryGroup>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let emptySearchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        if emptySearchHistoryGroup.visitHistories.count == 0 {
          self.deleteVisitHistoryGroup(emptySearchHistoryGroup)
        }
      }
    } catch {
      print("ModelContainerError deleteVisitHistoryGroupById")
    }
  }
  
  @MainActor static func getFrequentList() -> ArraySlice<VisitHistoryGroup>? {
    let descriptor = FetchDescriptor<VisitHistoryGroup>(
      predicate: #Predicate { $0.title != "" }
    )
    do {
      let visitHistoryGroupList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
        .sorted {
          $0.visitHistories.count > $1.visitHistories.count
        }
        .prefix(5)
      
      return visitHistoryGroupList
    } catch {
      print("ModelContainerError getFrequentList")
    }
    
    return nil
  }
}
