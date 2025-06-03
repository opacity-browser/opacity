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
  
  @MainActor static func moveBookamrkGroupToBase(baseGroup:BookmarkGroup, bookmarkGroup: BookmarkGroup) {
    let newBookmarkGroup = BookmarkGroup(index: baseGroup.bookmarkGroups.count, depth: 1, name: bookmarkGroup.name)
    self.deleteBookmarkGroup(bookmarkGroup: bookmarkGroup)
    baseGroup.bookmarkGroups.append(newBookmarkGroup)
  }
  
  @MainActor static func moveBookmarkGroupToBookmark(startBookmarkGroup: BookmarkGroup, endBookmark: Bookmark) {
    if let endParentGroup = endBookmark.bookmarkGroup {
      let startBookmarkGroupName = startBookmarkGroup.name
      self.deleteBookmarkGroup(bookmarkGroup: startBookmarkGroup)
      
      let newBookmarkGroup = BookmarkGroup(index: endParentGroup.bookmarkGroups.count, depth: endParentGroup.depth + 1, name: startBookmarkGroupName)
      endParentGroup.bookmarkGroups.append(newBookmarkGroup)
    }
  }
  
  @MainActor static func moveBookmark(from: Bookmark, to: Bookmark) {
    let endIndex = to.index
    // 파비콘 데이터도 함께 복사
    let newMoveBookmark = Bookmark(index: endIndex, title: from.title, url: from.url, favicon: from.favicon)
    
    if let toParentGroup = to.bookmarkGroup {
      self.deleteBookmark(bookmark: from)
      for (index, child) in toParentGroup.bookmarks.sorted(by: { $0.index < $1.index }).enumerated() {
        child.index = index >= endIndex ? index + 1 : index
      }
      toParentGroup.bookmarks.insert(newMoveBookmark, at: endIndex)
    }
  }
  
  @MainActor static func moveBookmarkGroup(from: BookmarkGroup, to: BookmarkGroup) {
    let endIndex = to.index
    let newMoveBookmarkGroup = BookmarkGroup(index: endIndex, depth: to.depth, name: from.name)
    
    if let toParentGroup = to.parent {
      self.deleteBookmarkGroup(bookmarkGroup: from)
      for (index, child) in toParentGroup.bookmarkGroups.sorted(by: { $0.index < $1.index }).enumerated() {
        child.index = index >= endIndex ? index + 1 : index
      }
      toParentGroup.bookmarkGroups.insert(newMoveBookmarkGroup, at: endIndex)
    }
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
}
