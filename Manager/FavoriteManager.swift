//
//  FavoriteManager.swift
//  Opacity
//
//  Created by Falsy on 4/5/24.
//

import SwiftUI
import SwiftData

class FavoriteManager {
  @MainActor static func getFavoriteList() -> [Favorite]? {
    var descriptor = FetchDescriptor<Favorite>()
    descriptor.fetchLimit = 5
    do {
      return try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
    } catch {
      print("ModelContainerError getFavoriteList")
    }
    return nil
  }
  
  @MainActor static func addFavorite(_ favorite: Favorite) -> Bool {
    do {
      AppDelegate.shared.opacityModelContainer.mainContext.insert(favorite)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
      return true
    } catch {
      print("ModelContainerError addFavorite")
    }
    return false
  }
  
  @MainActor static func deleteFavoriteById(_ id: String) -> Bool {
    if let uuid = UUID(uuidString: id) {
      var descriptor = FetchDescriptor<Favorite>(
        predicate: #Predicate { $0.id == uuid }
      )
      descriptor.fetchLimit = 1
      do {
        if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          AppDelegate.shared.opacityModelContainer.mainContext.delete(target)
          try AppDelegate.shared.opacityModelContainer.mainContext.save()
          return true
        }
      } catch {
        print("ModelContainerError deleteFavoriteById")
      }
    }
    return false
  }
  
  @MainActor static func editFavoriteById(_ id: UUID, newTitle: String, newAddress: String) -> Bool {
    var descriptor = FetchDescriptor<Favorite>(
      predicate: #Predicate { $0.id == id }
    )
    descriptor.fetchLimit = 1
    do {
      if let target = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        target.title = newTitle
        target.address = newAddress
        try AppDelegate.shared.opacityModelContainer.mainContext.save()
        return true
      }
    } catch {
      print("ModelContainerError editFavoriteById")
    }
    
    return false
  }
}
