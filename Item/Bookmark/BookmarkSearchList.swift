//
//  BookmarkSearchList.swift
//  Opacity
//
//  Created by Falsy on 3/14/24.
//

import SwiftUI

struct BookmarkSearchList: View {
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  var bookmarks: [Bookmark]
  @Binding var searchText: String
  
  var filteredItems: [Bookmark] {
    return bookmarks.filter { target in
      if let url = target.url {
        return target.title.localizedCaseInsensitiveContains(searchText) ||
          url.localizedCaseInsensitiveContains(searchText)
      } else {
        return false
      }
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, bookmark in
        VStack(spacing: 0) {
          BookmarkTitle(bookmarks: bookmarks, bookmark: bookmark, browser: browser, manualUpdate: manualUpdate)
        }
      }
    }
  }
}
