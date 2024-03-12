//
//  BookmarkAPI.swift
//  Opacity
//
//  Created by Falsy on 3/12/24.
//

import SwiftUI
import SwiftData

class BookmarkAPI {
  @MainActor static func addBookmark(index: Int, parent: Bookmark? = nil, title: String? = nil, url: String? = nil, favicon: Data? = nil) {
    do {
      var newBookmark: Bookmark
      if let title = title {
        newBookmark = Bookmark(index: index, title: title, parent: parent, url: url, favicon: favicon)
      } else {
        newBookmark = Bookmark(index: index, parent: parent, url: url, favicon: favicon)
      }
      AppDelegate.shared.opacityModelContainer.mainContext.insert(newBookmark)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
    } catch {
      print("bookmark insert error")
    }
  }
  
  @MainActor static func deleteIncludingChildren(_ bookmark: Bookmark) {
    if let childBookmark = bookmark.children {
      for childTarget in childBookmark {
        BookmarkAPI.deleteIncludingChildren(childTarget)
      }
    }
    AppDelegate.shared.opacityModelContainer.mainContext.delete(bookmark)
  }
  
  static func isBookmarkGroup(_ bookmark: Bookmark) -> Bool {
    return bookmark.url == nil
  }
  
  // bookmarks - A bookmark that is a sibling of the current bookmark
  // cacheParent - The parent bookmark of the current bookmark
  // bookmark - Current bookmark
  static func resetIndexByBookmark(bookmarks: [Bookmark], cacheParent: Bookmark? = nil, bookmark: Bookmark, isGroup: Bool? = false) {
    if let target = cacheParent, let parentTargetChildren = target.children {
      let cache = parentTargetChildren.filter({ target in
        BookmarkAPI.isBookmarkGroup(target) == isGroup && target.id != bookmark.id
      }).sorted {
        return $0.index < $1.index
      }

      for (index, _) in cache.enumerated() {
        cache[index].index = index
      }
      
      for child in parentTargetChildren {
        if let cacheData = cache.first(where: { $0.id == child.id }) {
          child.index = cacheData.index
        }
      }
    } else {
      let cache = bookmarks.filter({ target in
        BookmarkAPI.isBookmarkGroup(target) == isGroup && target.id != bookmark.id
      }).sorted {
        return $0.index < $1.index
      }
      
      for (index, _) in cache.enumerated() {
        cache[index].index = index
      }
      
      for child in bookmarks {
        if let cacheData = cache.first(where: { $0.id == child.id }) {
          child.index = cacheData.index
        }
      }
    }
  }
  
  @MainActor static func deleteBookmarkGroup(bookmarks: [Bookmark], bookmark: Bookmark) {
    do {
      let cacheParent = bookmark.parent
      BookmarkAPI.deleteIncludingChildren(bookmark)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
      BookmarkAPI.resetIndexByBookmark(bookmarks: bookmarks, cacheParent: cacheParent, bookmark: bookmark, isGroup: true)
    } catch {
      print("bookmark group delete error")
    }
  }
  
  @MainActor static func deleteBookmark(bookmarks: [Bookmark], bookmark: Bookmark) {
    do {
      let cacheParent = bookmark.parent
      BookmarkAPI.deleteIncludingChildren(bookmark)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
      BookmarkAPI.resetIndexByBookmark(bookmarks: bookmarks, cacheParent: cacheParent, bookmark: bookmark)
    } catch {
      print("bookmark delete error")
    }
  }
  
  @MainActor static func changeGroupBookmark() {
    
  }
}
