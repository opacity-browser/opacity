//
//  PermissionManager.swift
//  Opacity
//
//  Created by Falsy on 3/31/24.
//

import SwiftUI
import SwiftData

class PermissionManager {
  
  @MainActor static func getLocationPermisionByURL(url: URL) -> DomainPermission? {
    if let host = url.host {
      let rawType = DomainPermissionType.geoLocation.rawValue
      let descriptor = FetchDescriptor<DomainPermission>(
        predicate: #Predicate { $0.permission == rawType && $0.domain == host }
      )
      do {
        if let locaitonPermision = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          return locaitonPermision
        }
      } catch {
        print("getLocationPermisions error")
      }
    }
    return nil
  }
  
  @MainActor static func getLocationPermisions() -> [DomainPermission]? {
    let rawType = DomainPermissionType.geoLocation.rawValue
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.permission == rawType }
    )
    do {
      let notificationPermisions = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return notificationPermisions
    } catch {
      print("getLocationPermisions error")
    }
    return nil
  }
  
  @MainActor static func getNotificationPermisions() -> [DomainPermission]? {
    let rawType = DomainPermissionType.notification.rawValue
    let descriptor = FetchDescriptor<DomainPermission>(
      predicate: #Predicate { $0.permission == rawType }
    )
    do {
      let notificationPermisions = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      return notificationPermisions
    } catch {
      print("getNotificationPermisions error")
    }
    return nil
  }
  
  @MainActor static func deletePermisionById(_ id: UUID) {
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
  
  @MainActor static func updatePermisionById(id: UUID, isDenied: Bool) {
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
