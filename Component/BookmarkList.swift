//
//  BookmarkList.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI
import SwiftData

struct BookmarkItem: View {
  @Environment(\.modelContext) var modelContext
  var bookmarks: [Bookmark]
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  
  init(bookmarks: [Bookmark], browser: Browser, manualUpdate: ManualUpdate) {
    self.bookmarks = bookmarks.sorted {
      $0.index < $1.index
    }.sorted {
      if $0.url == nil && $1.url != nil {
        return true
      }
      return false
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
                  BookmarkItem(bookmarks: childBookmark, browser: browser, manualUpdate: manualUpdate)
                }
              }
            })
          }
        }
      }
    }
    .padding(.leading, 10)
  }
}

struct BookmarkList: View {
  @Environment(\.modelContext) var modelContext

  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  var bookmarks: [Bookmark]
  
  var body: some View {
    VStack {
      BookmarkItem(bookmarks: bookmarks, browser: browser, manualUpdate: manualUpdate)
    }
  }
}
