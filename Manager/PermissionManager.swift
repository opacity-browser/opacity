//
//  PermissionManager.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI
import SwiftData

class PermissionManager {
  @MainActor static func getNotificationPermisions() -> [DomainPermission]? {
    let rawType = DomainPermissionType.notification.rawValue
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.permission == rawType }
    )
    do {
      let notificationPermisions = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return notificationPermisions
    } catch {
      print("get visit history group error")
    }
    return nil
  }
  
  @MainActor static func deleteNotificationPermisionById(_ id: UUID) {
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      }
    } catch {
      print("delete notification permission by id error")
    }
  }
  
  @MainActor static func updateNotificationPermisionById(id: UUID, isDenied: Bool) {
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        target.isDenied = isDenied
      }
    } catch {
      print("update notification permission by id error")
    }
  }
}
