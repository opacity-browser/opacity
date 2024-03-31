//
//  NotiDomain.swift
//  Opacity
//
//  Created by Falsy on 2/28/24.
//

import SwiftUI
import SwiftData

enum DomainPermissionType: Int, Codable {
  case notification = 1
}

@Model
class DomainPermission {
  var id: UUID
  var domain: String
  var permission: Int
  var isDenied: Bool
  
  init(domain: String, permission: DomainPermissionType.RawValue, isDenied: Bool) {
    self.id = UUID()
    self.domain = domain
    self.permission = permission
    self.isDenied = isDenied
  }
}
