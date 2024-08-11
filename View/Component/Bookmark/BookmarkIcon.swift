//
//  BookmarkIcon.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

struct BookmarkIcon: View {
  @Query var bookmarks: [Bookmark]
  
  @ObservedObject var tab: Tab
  
  @State private var isBookmarkHover: Bool = false
  @State private var isBookmarkDialog: Bool = false
  
  var body: some View {
    Button {
      self.isBookmarkDialog.toggle()
    } label: {
      VStack(spacing: 0) {
        if let _ = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
          Image(systemName: "bookmark.fill")
            .foregroundColor(Color("Point"))
            .font(.system(size: 14))
            .fontWeight(.regular)
        } else {
          Image(systemName: "bookmark")
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
        }
      }
      .frame(maxWidth: 24, maxHeight: 24)
      .background(isBookmarkHover ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .onHover { hovering in
        withAnimation {
          isBookmarkHover = hovering
        }
      }
      .popover(isPresented: $isBookmarkDialog, arrowEdge: .bottom) {
        BookmarkDialog(tab: tab, bookmarks: bookmarks, onClose: {
          self.isBookmarkDialog = false
        })
      }
    }
    .buttonStyle(.plain)
  }
}
