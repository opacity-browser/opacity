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
  @Binding var directUpdate: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
        ExpandList(bookmark: bookmark, title: {
          BookmarkTitle(bookmark: bookmark, directUpdate: $directUpdate)
        }, content: {
          HStack(spacing: 0) {
            if let childBookmark = bookmark.children, childBookmark.count > 0 {
              BookmarkItem(bookmarks: childBookmark, directUpdate: $directUpdate)
             }
          }
        })
      }
    }
    .padding(.leading, 10)
  }
}

struct BookmarkBox: View {
  var bookmarks: [Bookmark]
  @State var directUpdate: Bool = false
  
  var body: some View {
    BookmarkItem(bookmarks: bookmarks, directUpdate: $directUpdate)
  }
}

struct BookmarkList: View {
  @Environment(\.modelContext) var modelContext
  @Query var allBookmarks: [Bookmark]
  @Query(filter: #Predicate<Bookmark> {
    $0.parent == nil
  }) var bookmarks: [Bookmark]
  @State var directUpdate: Bool = false
  
  var body: some View {
    VStack {
      BookmarkItem(bookmarks: bookmarks, directUpdate: $directUpdate)
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
