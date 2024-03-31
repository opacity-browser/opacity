//
//  permissionItem.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI

class PermissionItem: Codable {
  var id: UUID
  var domain: String
  var permission: Int
  var isDenied: Bool
  
  init(id: UUID, domain: String, permission: Int, isDenied: Bool) {
    self.id = id
    self.domain = domain
    self.permission = permission
    self.isDenied = isDenied
  }
}
