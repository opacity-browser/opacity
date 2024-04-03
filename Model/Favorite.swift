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
  var id: UUID
  var title: String
  var address: String
  
  init(title: String, address: String) {
    self.id = UUID()
    self.title = title
    self.address = address
  }
}

