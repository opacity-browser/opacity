//
//  BookmarkSearchList.swift
//  Opacity
//
//  Created by Falsy on 3/14/24.
//

import SwiftUI

struct BookmarkSearchList: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  var bookmarks: [Bookmark]
  @Binding var searchText: String
  
  var filteredItems: [Bookmark] {
    return bookmarks.filter { target in
      return target.title.localizedCaseInsensitiveContains(searchText) ||
        target.url.localizedCaseInsensitiveContains(searchText)
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, bookmark in
        VStack(spacing: 0) {
          BookmarkTitleNSView(service: service, browser: browser, bookmark: bookmark, enabledDrag: false)
        }
      }
    }
  }
}
