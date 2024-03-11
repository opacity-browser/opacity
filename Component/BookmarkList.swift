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
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
        VStack(spacing: 0) {
          if let _ = bookmark.url {
            BookmarkTitle(bookmark: bookmark, browser: browser, manualUpdate: manualUpdate)
              .padding(.leading, 14)
          } else {
            ExpandList(bookmark: bookmark, title: {
              BookmarkGroupTitle(bookmark: bookmark, manualUpdate: manualUpdate)
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
  @Query(filter: #Predicate<Bookmark> {
    $0.parent == nil
  }) var bookmarks: [Bookmark]
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  
  var body: some View {
    VStack {
      BookmarkItem(bookmarks: bookmarks, browser: browser, manualUpdate: manualUpdate)
    }
    .onAppear {
      if bookmarks.count == 0 {
        do {
          let newBookmark = Bookmark()
          modelContext.insert(newBookmark)
          try modelContext.save()
        } catch {
          print("init bookmark insert error")
        }
      }
    }
  }
}
