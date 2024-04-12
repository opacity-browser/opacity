//
//  VisitHistorySettings.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI

struct VisitHistorySettings: Codable {
  var id: UUID
  var title: String
  var url: String
  var createDate: String
  
  init(id: UUID, title: String?, url: String, createDate: String) {
    self.id = id
    self.title = title ?? ""
    self.url = url
    self.createDate = createDate
  }
}
