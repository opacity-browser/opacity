//
//  Parameters.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI

class UpdatePermissionParams: Codable {
  var id: String
  var isDenied: Bool
  
  init(id: String, isDenied: Bool) {
    self.id = id
    self.isDenied = isDenied
  }
}
