//
//  VisitManager.swift
//  Opacity
//
//  Created by Falsy on 3/25/24.
//

import SwiftUI
import SwiftData

class VisitManager {
  
  @MainActor static func findVisitHistoryGroup(_ keyword: String) -> [VisitHistoryGroup]? {
    let lowercaseKeyword = keyword.lowercased()
    var descriptor = FetchDescriptor<VisitHistoryGroup>(
      predicate: #Predicate<VisitHistoryGroup> { visit in
        if let title = visit.title {
          return visit.url.contains(lowercaseKeyword) || title.contains(lowercaseKeyword)
        } else {
          return visit.url.contains(lowercaseKeyword)
        }
      },
      sortBy: [SortDescriptor(\VisitHistoryGroup.updateDate, order: .reverse)]
    )
    descriptor.fetchLimit = 5
    
    do {
      let visitHistoryGroupList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return visitHistoryGroupList
    } catch {
      print("ModelContainerError findVisitHistoryGroup")
      print(error)
    }
    
    return nil
  }
  
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
  
  // 최근 방문한 기록 가져오기 (리다이렉트 판단용)
  @MainActor static func getRecentVisitHistoryGroup() -> VisitHistoryGroup? {
    var descriptor = FetchDescriptor<VisitHistoryGroup>(
      sortBy: [SortDescriptor(\VisitHistoryGroup.updateDate, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    
    do {
      let recentGroups = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return recentGroups.first
    } catch {
      print("Error fetching recent visit history group: \(error)")
      return nil
    }
  }
  
  // 리다이렉트 URL인지 판단 (www 추가/제거, http/https 변경)
  @MainActor static func areRedirectURLs(from: URL, to: URL) -> Bool {
    // 같은 URL이면 리다이렉트가 아님
    if from.absoluteString == to.absoluteString {
      return false
    }
    
    // 도메인 정규화 함수
    func normalizeDomain(_ host: String?) -> String? {
      guard let host = host?.lowercased() else { return nil }
      return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
    
    // 도메인이 같고 경로도 같으면 리다이렉트로 판단
    let fromNormalizedDomain = normalizeDomain(from.host)
    let toNormalizedDomain = normalizeDomain(to.host)
    
    return fromNormalizedDomain == toNormalizedDomain && 
           from.path == to.path &&
           from.query == to.query
  }
  
  @MainActor static func addVisitHistory(url: String, title: String? = nil, faviconData: Data? = nil) {
    
    // about:blank URL은 기록하지 않음
    if url == "about:blank" || url.hasPrefix("about:") {
      return
    }
    
    // 리다이렉트 중복 방지 (같은 도메인의 www 추가/제거)
    if let recentGroup = getRecentVisitHistoryGroup(), 
       let recentURL = URL(string: recentGroup.url),
       let currentURL = URL(string: url),
       // 최근 30초 이내의 기록만 리다이렉트로 판단
       Date().timeIntervalSince(recentGroup.updateDate) < 30,
       areRedirectURLs(from: recentURL, to: currentURL) {
      // 리다이렉트로 판단되면 기존 기록의 URL을 최종 URL로 업데이트
      recentGroup.url = url
      if let title = title, !title.isEmpty {
        recentGroup.title = title
      }
      if let faviconData = faviconData {
        recentGroup.faviconData = faviconData
      }
      // updateDate 갱신
      recentGroup.updateDate = Date()
      return
    }
    
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
      // 파비콘 데이터가 없거나 새로운 파비콘 데이터가 있으면 업데이트
      if visitGroup.faviconData == nil, let faviconData = faviconData {
        visitGroup.faviconData = faviconData
        do {
          try AppDelegate.shared.opacityModelContainer.mainContext.save()
        } catch {
          print("ModelContainerError updating favicon")
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
  
  @MainActor static func updateVisitHistoryGroupFavicon(url: String, faviconData: Data) {
    if let visitGroup = self.getVisitHistoryGroup(url) {
      visitGroup.faviconData = faviconData
      do {
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      } catch {
        print("ModelContainerError updateVisitHistoryGroupFavicon")
      }
    }
  }
  
  @MainActor static func deleteAllVisitHistory() {
    let descriptor = FetchDescriptor<VisitHistory>()
    let descriptorGroup = FetchDescriptor<VisitHistoryGroup>()
    do {
      let allVisitHistory = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      let allVisitHistoryGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptorGroup)
      for visitHistory in allVisitHistory {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(visitHistory)
      }
      for vhGroup in allVisitHistoryGroup {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(vhGroup)
      }
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
       print("ModelContainerError deleteAllVisitHistory")
     }
  }
  
  @MainActor static func deleteVisitHistoryGroup(_ target: VisitHistoryGroup) {
    for visitHistory in target.visitHistories {
      AppDelegate.shared.opacityModelContainer.mainContext.delete(visitHistory)
    }
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
        if emptySearchHistoryGroup.visitHistories.isEmpty {
          self.deleteVisitHistoryGroup(emptySearchHistoryGroup)
        }
      }
    } catch {
      print("ModelContainerError deleteVisitHistoryGroupById")
    }
  }
}
