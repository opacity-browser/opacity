//
//  BookmarkList.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI
import SwiftData

struct BookmarkItem: View {
  @ObservedObject var browser: Browser
  
  var bookmarks: [Bookmark]
  var bookmarkGroups: [BookmarkGroup]
  
  init(browser: Browser, bookmarkGroup: BookmarkGroup) {
    self.browser = browser
    self.bookmarks = bookmarkGroup.bookmarks.sorted {
      $0.index < $1.index
    }
    self.bookmarkGroups = bookmarkGroup.bookmarkGroups.sorted {
      $0.index < $1.index
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(bookmarkGroups.enumerated()), id: \.element.id) { index, bookmarkGroup in
        ExpandList(bookmarkGroup: bookmarkGroup, title: {
          BookmarkGroupTitle(bookmarkGroup: bookmarkGroup)
        }, content: {
          if bookmarkGroup.bookmarks.count > 0 || bookmarkGroup.bookmarkGroups.count > 0 {
            BookmarkItem(browser: browser, bookmarkGroup: bookmarkGroup)
          }
        })
      }
      ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
        BookmarkTitle(browser: browser, bookmark: bookmark)
          .padding(.leading, 14)
      }
    }
    .padding(.leading, 15)
  }
}

struct BookmarkList: View {
  @ObservedObject var browser: Browser
  
  @Query(filter: #Predicate<BookmarkGroup> {
    $0.isBase == true
  }) var baseBookmarkGroup: [BookmarkGroup]
  
  @Query var bookmarkGroups: [BookmarkGroup]
  @Query var bookmarks: [Bookmark]
  
  func getHash() -> Int {
    var hasher = Hasher()
    hasher.combine(bookmarks)
    hasher.combine(bookmarkGroups)
    return hasher.finalize()
  }
  
  var body: some View {
    VStack {
      if let bookmarkGroup = baseBookmarkGroup.first {
        BookmarkItem(browser: browser, bookmarkGroup: bookmarkGroup)
          .id(getHash())
      }
    }
  }
}
