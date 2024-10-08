//
//  BookmarkDialog.swift
//  Opacity
//
//  Created by Falsy on 3/11/24.
//

import SwiftUI
import SwiftData

struct BookmarkDialog: View {
  @Query var bookmarkGroups: [BookmarkGroup]
  
  @ObservedObject var tab: Tab
  var bookmarks: [Bookmark]
  var onClose: () -> Void
  
  @State private var bookmarkTitle: String = ""
  @State private var selectId: UUID?
  
  init(tab: Tab, bookmarks: [Bookmark], onClose: @escaping () -> Void) {
    self.tab = tab
    self.onClose = onClose
    self.bookmarks = bookmarks
    if let bookmark = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
      self._bookmarkTitle = State(initialValue: bookmark.title)
      if let parentId = bookmark.bookmarkGroup?.id {
        self._selectId = State(initialValue: parentId)
      }
    } else {
      self._bookmarkTitle = State(initialValue: tab.title)
      if let baseGroup = BookmarkManager.getBaseBookmarkGroup() {
        self._selectId = State(initialValue: baseGroup.id)
      }
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(NSLocalizedString("Name", comment: ""))
          .font(.system(size: 12))
        Spacer()
        ZStack {
          Rectangle()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(Color("SearchBarBG"))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(0)
          TextField(NSLocalizedString("Name", comment: ""), text: $bookmarkTitle)
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.horizontal, 5)
            .font(.system(size: 12))
            .frame(height: 20)
        }
        .frame(width: 145, height: 20)
      }
      .padding(.bottom, 7)
      HStack(spacing: 0) {
        Text(NSLocalizedString("Folder", comment: ""))
          .font(.system(size: 12))
        Spacer()
        Picker("", selection: $selectId) {
          ForEach(bookmarkGroups
              .sorted { $0.index < $1.index }
              .sorted { $0.depth < $1.depth }, id: \.id) { target in
            Text(target.name).tag(target.id as UUID?)
          }
        }
        .frame(width: 153)
      }
      .padding(.bottom, 15)
      HStack(spacing: 0) {
        Button {
          if !bookmarkTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let bookmark = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
              BookmarkManager.deleteBookmark(bookmark: bookmark)
            }
            if let bookmarkGroupId = selectId, let bookmarkGroup = bookmarkGroups.first(where: { $0.id == bookmarkGroupId }) {
              BookmarkManager.addBookmark(bookmarkGroup: bookmarkGroup, title: bookmarkTitle, url: tab.originURL.absoluteString, favicon: tab.faviconData)
              bookmarkGroup.isOpen = true
            }
            onClose()
          }
        } label: {
          Text(NSLocalizedString("Save", comment: ""))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DialogPermissonStyle())
        .frame(maxWidth: .infinity)
        
        if let bookmark = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
          HStack(spacing: 0) { }
            .frame(width: 12)
          
          Button {
            BookmarkManager.deleteBookmark(bookmark: bookmark)
            onClose()
          } label: {
            Text(NSLocalizedString("Delete", comment: ""))
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(DialogPermissonStyle())
          .frame(maxWidth: .infinity)
        }
      }
    }
    .padding(.top, 20)
    .padding(.horizontal, 20)
    .padding(.bottom, 15)
    .frame(width: 260)
    .background(GeometryReader { geometry in
      Color("DialogBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
}
