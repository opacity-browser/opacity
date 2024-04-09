//
//  VisitHistoryCount.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

@Model
class VisitHistoryGroup {
  @Attribute(.unique)
  var id: UUID
  
  @Attribute(.unique)
  var url: String
  
  var title: String?
  
  var faviconData: Data?

  @Relationship(deleteRule: .cascade, inverse: \VisitHistory.visitHistoryGroup)
  var visitHistories: [VisitHistory] = [VisitHistory]()

  var updateDate: Date
  
  init(url: String, title: String? = nil, faviconData: Data? = nil) {
    self.id = UUID()
    self.url = url
    self.title = title
    self.faviconData = faviconData
    self.updateDate = Date.now
  }
  
  @Transient
  static func getFaviconData(url: URL) async -> Data? {
    do {
      let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
      return data
    } catch {
      print("Failed to fetch favicon data: \(error)")
      return nil
    }
  }
}
