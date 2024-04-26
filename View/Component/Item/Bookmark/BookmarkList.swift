//
//  BookmarkList.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI
import SwiftData

struct BookmarkItem: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  
  var bookmarks: [Bookmark]
  var bookmarkGroups: [BookmarkGroup]
  
  init(service: Service, browser: Browser, bookmarkGroup: BookmarkGroup) {
    self.service = service
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
          BookmarkGroupTitleNSView(service: service, bookmarkGroup: bookmarkGroup)
        }, content: {
          if bookmarkGroup.bookmarks.count > 0 || bookmarkGroup.bookmarkGroups.count > 0 {
            BookmarkItem(service: service, browser: browser, bookmarkGroup: bookmarkGroup)
          }
        })
      }
      ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
        BookmarkTitleNSView(service: service, browser: browser, bookmark: bookmark, enabledDrag: true)
          .padding(.leading, 10)
      }
    }
    .padding(.leading, 15)
  }
}

struct BookmarkList: View {
  @ObservedObject var service: Service
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
    VStack(spacing: 0) {
      if let bookmarkGroup = baseBookmarkGroup.first {
        BookmarkItem(service: service, browser: browser, bookmarkGroup: bookmarkGroup)
          .id(getHash())
      }
    }
  }
}
