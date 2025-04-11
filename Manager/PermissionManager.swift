//
//  PermissionManager.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI
import SwiftData

class PermissionManager {
  
  @MainActor static func getLocationPermissionByURL(url: URL) -> DomainPermission? {
    if let host = url.host {
      let rawType = DomainPermissionType.geoLocation.rawValue
      let descriptor = FetchDescriptor<DomainPermission>(
        predicate: #Predicate { $0.permission == rawType && $0.domain == host }
      )
      do {
        if let locaitonPermission = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          return locaitonPermission
        }
      } catch {
        print("getLocationPermissions error")
      }
    }
    return nil
  }
  
  @MainActor static func getLocationPermissions() -> [DomainPermission]? {
    let rawType = DomainPermissionType.geoLocation.rawValue
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.permission == rawType }
    )
    do {
      let notificationPermissions = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return notificationPermissions
    } catch {
      print("getLocationPermissions error")
    }
    return nil
  }
  
  @MainActor static func getNotificationPermissions() -> [DomainPermission]? {
    let rawType = DomainPermissionType.notification.rawValue
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.permission == rawType }
    )
    do {
      let notificationPermissions = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return notificationPermissions
    } catch {
      print("getNotificationPermissions error")
    }
    return nil
  }
  
  @MainActor static func deletePermissionById(_ id: UUID) {
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
      }
    } catch {
      print("delete permission by id error")
    }
  }
  
  @MainActor static func updatePermissionById(id: UUID, isDenied: Bool) {
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.id == id }
    )
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        target.isDenied = isDenied
      }
    } catch {
      print("update permission by id error")
    }
  }
}
