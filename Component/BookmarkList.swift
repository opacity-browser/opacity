//
//  BookmarkList.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI

struct BookmarkList: View {
  var bookmarks: [Bookmark]
  
  var body: some View {
    ForEach(bookmarks) { targetBookmark in
      VStack(spacing: 0) {
        Text(targetBookmark.title)
      }
    }
  }
}
