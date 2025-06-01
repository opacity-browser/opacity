//
//  Favorite.swift
//  Opacity
//
//  Created by Falsy on 4/3/24.
//

import SwiftUI
import SwiftData

@Model
class Favorite {
  @Attribute(.unique)
  var id: UUID
  var title: String
  var address: String
  var createDate: Date = Date.now
  
  init(title: String, address: String) {
    self.id = UUID()
    self.title = title
    self.address = address
    self.createDate = Date.now
  }
}

