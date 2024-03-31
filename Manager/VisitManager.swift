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
      print("get visit history group error")
    }
    return nil
  }
  
  @MainActor static func addVisitHistory(url: String, title: String? = nil, faviconData: Data? = nil) {
    if let visitGroup = self.getVisitHistoryGroup(url) {
      let currentDate = Date()
      if visitGroup.visitHistories?.count == 0 || currentDate.timeIntervalSince(visitGroup.updateDate) > 60 {
        let newVisitHistory = VisitHistory(visitHistoryGroup: visitGroup)
        visitGroup.visitHistories?.append(newVisitHistory)
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
        print("add search history, search history group error")
      }
    }
  }
  
  @MainActor static func deleteVisitHistory(_ target: VisitHistory) {
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("delete visit history error")
    }
  }
  
  @MainActor static func deleteVisitHistoryGroup(_ target: VisitHistoryGroup) {
    if let visitHistories = target.visitHistories {
      for visitHistory in visitHistories {
        self.deleteVisitHistory(visitHistory)
      }
    }
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
       print("delete visit history group error")
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
      print("delete visit history error")
    }
  }
  
  @MainActor static func deleteVisitHistoryGroupById(_ id: UUID) {
    let descriptor = FetchDescriptor<VisitHistoryGroup>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let emptySearchHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        if emptySearchHistoryGroup.visitHistories!.count == 0 {
          self.deleteVisitHistoryGroup(emptySearchHistoryGroup)
        }
      }
    } catch {
      print("get empty visit history group error")
    }
  }
}
