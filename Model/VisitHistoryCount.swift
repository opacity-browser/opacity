//
//  VisitHistoryCount.swift
//  Opacity
//
//  Created by Falsy on 3/15/24.
//

import SwiftUI
import SwiftData

@Model
class VisitHistoryCount {
  @Attribute(.unique)
  var url: String
  var count: UInt
  
  init(url: String) {
    self.url = url
    self.count = 1
  }
}
