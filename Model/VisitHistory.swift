//
//  VisitHistory.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

@Model
class VisitHistory {
  @Attribute(.unique)
  var id: UUID
  
  var url: String
  var title: String
  var favicon: Data?
  var createDate: Date
  
  init(url: String, title: String, favicon: Data? = nil) {
    self.id = UUID()
    self.url = url
    self.title = title
    self.favicon = favicon
    self.createDate = Date.now
  }
}

