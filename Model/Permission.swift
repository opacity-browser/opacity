//
//  Permission.swift
//  Opacity
//
//  Created by Falsy on 2/26/24.
//

import SwiftUI

final class Permission: ObservableObject {
  @Published var isShowLocationDialog: Bool = false
  @Published var isShowNotificationDialog: Bool = false
  
  func clearIsShowDialog() {
    isShowLocationDialog = false
    isShowNotificationDialog = false
  }
}
