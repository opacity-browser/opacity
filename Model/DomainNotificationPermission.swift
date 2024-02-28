//
//  NotiDomain.swift
//  Opacity
//
//  Created by Falsy on 2/28/24.
//

import SwiftData

@Model
class DomainNotificationPermission {
  @Attribute(.unique)
  var domain: String
  var isDenied: Bool
  
  init(domain: String, status: Bool) {
    self.domain = domain
    self.isDenied = status
  }
}
