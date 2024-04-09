//
//  BookmarkAPI.swift
//  Opacity
//
//  Created by Falsy on 3/12/24.
//

import SwiftUI
import SwiftData

class BookmarkManager {
  
  private static var cacheBaseBookmarkGroup: BookmarkGroup?
  
  @MainActor static func getBaseBookmarkGroup() -> BookmarkGroup? {
    if let cacheBaseBookmarkGroup = cacheBaseBookmarkGroup {
      return cacheBaseBookmarkGroup
    }
    
    let baseBookmarkGroupDescriptor = FetchDescriptor<BookmarkGroup>(
      predicate: #Predicate { $0.isBase == true }
    )
    do {
      if let baseBookmarkGroup = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(baseBookmarkGroupDescriptor).first {
        cacheBaseBookmarkGroup = baseBookmarkGroup
        return baseBookmarkGroup
      }
    } catch {
      print("ModelContainerError getBaseBookmarkGroup")
    }
    
    return nil
  }
  
  @MainActor static func addBookmark(bookmarkGroup: BookmarkGroup, title: String = "", url: String, favicon: Data? = nil) {
    bookmarkGroup.bookmarks.append(Bookmark(index: bookmarkGroup.bookmarks.count, title: title, url: url, favicon: favicon))
  }
  
  @MainActor static func addBookmarkGroup(parentGroup: BookmarkGroup) {
    parentGroup.bookmarkGroups.append(BookmarkGroup(index: parentGroup.bookmarkGroups.count, depth: parentGroup.depth + 1))
  }
  
  @MainActor static func deleteBookmark(bookmark: Bookmark) {
    do {
      let cacheBookmarkGroup = bookmark.bookmarkGroup!
      AppDelegate.shared.opacityModelContainer.mainContext.delete(bookmark)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
      self.resetIndexByBookmark(parentGroup: cacheBookmarkGroup)
    } catch {
      print("ModelContainerError deleteBookmarkGroup")
    }
  }
  
  @MainActor static func deleteChildBookmarkGroup(childBookmarkGroup: BookmarkGroup) {
    for childBookmark in childBookmarkGroup.bookmarks {
      self.deleteBookmark(bookmark: childBookmark)
    }
    for childChildBookmarkGroup in childBookmarkGroup.bookmarkGroups {
      self.deleteChildBookmarkGroup(childBookmarkGroup: childChildBookmarkGroup)
    }
    AppDelegate.shared.opacityModelContainer.mainContext.delete(childBookmarkGroup)
  }
  
  @MainActor static func deleteBookmarkGroup(bookmarkGroup: BookmarkGroup) {
    for childBookmark in bookmarkGroup.bookmarks {
      self.deleteBookmark(bookmark: childBookmark)
    }
    for childBookmarkGroup in bookmarkGroup.bookmarkGroups {
      self.deleteChildBookmarkGroup(childBookmarkGroup: childBookmarkGroup)
    }
    do {
      let cacheBookmarkGroup = bookmarkGroup.parent!
      AppDelegate.shared.opacityModelContainer.mainContext.delete(bookmarkGroup)
      try AppDelegate.shared.opacityModelContainer.mainContext.save()
      self.resetIndexByBookmarkGroup(parentGroup: cacheBookmarkGroup)
    } catch {
      print("ModelContainerError deleteBookmarkGroup")
    }
  }
  
  @MainActor static func resetIndexByBookmark(parentGroup: BookmarkGroup) {
    for (index, child) in parentGroup.bookmarks.sorted(by: { $0.index < $1.index }).enumerated() {
      child.index = index
    }
  }
  
  @MainActor static func resetIndexByBookmarkGroup(parentGroup: BookmarkGroup) {
    for (index, child) in parentGroup.bookmarkGroups.sorted(by: { $0.index < $1.index }).enumerated() {
      child.index = index
    }
  }
  
  
  
//  @MainActor static func addBookmark(index: Int, parent: Bookmark? = nil, title: String? = nil, url: String? = nil, favicon: Data? = nil) {
//    do {
//      var newBookmark: Bookmark
//      if let title = title {
//        newBookmark = Bookmark(index: index, title: title, parent: parent, url: url, favicon: favicon)
//      } else {
//        newBookmark = Bookmark(index: index, parent: parent, url: url, favicon: favicon)
//      }
//      AppDelegate.shared.opacityModelContainer.mainContext.insert(newBookmark)
//      try AppDelegate.shared.opacityModelContainer.mainContext.save()
//    } catch {
//      print("ModelContainerError addBookmark")
//    }
//  }
  
//  @MainActor static func deleteIncludingChildren(_ bookmark: Bookmark) {
//    for childTarget in bookmark.children {
//      self.deleteIncludingChildren(childTarget)
//    }
//    AppDelegate.shared.opacityModelContainer.mainContext.delete(bookmark)
//  }
//  
//  static func isBookmarkGroup(_ bookmark: Bookmark) -> Bool {
//    return bookmark.url == nil
//  }
//  
//  // bookmarks - A bookmark that is a sibling of the current bookmark
//  // cacheParent - The parent bookmark of the current bookmark
//  // bookmark - Current bookmark
//  static func resetIndexByBookmark(bookmarks: [Bookmark], cacheParent: Bookmark?, bookmark: Bookmark, isGroup: Bool? = false) {
//    if let target = cacheParent {
//      let cache = target.children.filter({ target in
//        self.isBookmarkGroup(target) == isGroup && target.id != bookmark.id
//      }).sorted {
//        return $0.index < $1.index
//      }
//
//      for (index, _) in cache.enumerated() {
//        cache[index].index = index
//      }
//      
//      for child in target.children {
//        if let cacheData = cache.first(where: { $0.id == child.id }) {
//          child.index = cacheData.index
//        }
//      }
//    } else {
//      let cache = bookmarks.filter({ target in
//        self.isBookmarkGroup(target) == isGroup && target.id != bookmark.id
//      }).sorted {
//        return $0.index < $1.index
//      }
//      
//      for (index, _) in cache.enumerated() {
//        cache[index].index = index
//      }
//      
//      for child in bookmarks {
//        if let cacheData = cache.first(where: { $0.id == child.id }) {
//          child.index = cacheData.index
//        }
//      }
//    }
//  }
//  
//  @MainActor static func deleteBookmarkGroup(bookmarks: [Bookmark], bookmark: Bookmark) {
//    do {
//      let cacheParent = bookmark.parent
//      self.deleteIncludingChildren(bookmark)
//      try AppDelegate.shared.opacityModelContainer.mainContext.save()
//      self.resetIndexByBookmark(bookmarks: bookmarks, cacheParent: cacheParent, bookmark: bookmark, isGroup: true)
//    } catch {
//      print("ModelContainerError deleteBookmarkGroup")
//    }
//  }
//  
//  @MainActor static func deleteBookmark(bookmarks: [Bookmark], bookmark: Bookmark) {
//    do {
//      let cacheParent = bookmark.parent
//      self.deleteIncludingChildren(bookmark)
//      try AppDelegate.shared.opacityModelContainer.mainContext.save()
//      self.resetIndexByBookmark(bookmarks: bookmarks, cacheParent: cacheParent, bookmark: bookmark)
//    } catch {
//      print("ModelContainerError deleteBookmark")
//    }
//  }
}
