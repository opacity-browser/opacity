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
  @ObservedObject var manualUpdate: ManualUpdate
  var bookmarks: [Bookmark]
  
  init(browser: Browser, manualUpdate: ManualUpdate, bookmarks: [Bookmark]) {
    self.bookmarks = bookmarks.sorted {
      $0.index < $1.index
    }.sorted {
      $0.url == nil && $1.url != nil
    }
    self.browser = browser
    self.manualUpdate = manualUpdate
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
        VStack(spacing: 0) {
          if let _ = bookmark.url {
            BookmarkTitle(bookmarks: bookmarks, bookmark: bookmark, browser: browser, manualUpdate: manualUpdate)
              .padding(.leading, 14)
          } else {
            ExpandList(bookmark: bookmark, title: {
              BookmarkGroupTitle(bookmarks: bookmarks, bookmark: bookmark, manualUpdate: manualUpdate)
            }, content: {
              HStack(spacing: 0) {
                if let childBookmark = bookmark.children, childBookmark.count > 0 {
                  BookmarkItem(browser: browser, manualUpdate: manualUpdate, bookmarks: childBookmark)
                }
              }
            })
          }
        }
      }
    }
    .padding(.leading, 15)
  }
}

struct BookmarkList: View {
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  var bookmarks: [Bookmark]
  
  var body: some View {
    VStack {
      BookmarkItem(browser: browser, manualUpdate: manualUpdate, bookmarks: bookmarks)
    }
  }
}
