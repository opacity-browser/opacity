//
//  BookmarkAPI.swift
//  Opacity
//
//  Created by Falsy on 3/12/24.
//

import SwiftUI
import SwiftData

class BookmarkAPI {
  @MainActor static func addBookmark(index: Int, parent: Bookmark? = nil) {
    do {
      let newBookmark = Bookmark(index: index, parent: parent)
      AppDelegate.shared.opacityModelContainer.mainContext.insert(newBookmark)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("bookmark insert error")
    }
  }
}
