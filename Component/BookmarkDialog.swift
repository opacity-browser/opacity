//
//  BookmarkDialog.swift
//  Opacity
//
//  Created by Falsy on 3/11/24.
//

import SwiftUI
import SwiftData

struct BookmarkDialog: View {
  @Environment(\.modelContext) var modelContext

  @ObservedObject var tab: Tab
  var bookmarks: [Bookmark]
  var bookmarkGroups: [Bookmark]
  @ObservedObject var manualUpdate: ManualUpdate
  var onClose: () -> Void
  @State private var bookmarkTitle: String = ""
  @State private var selectId: UUID?
  
  init(tab: Tab, bookmarks: [Bookmark], bookmarkGroups: [Bookmark], manualUpdate: ManualUpdate,onClose: @escaping () -> Void) {
    self.tab = tab
    self.onClose = onClose
    self.bookmarks = bookmarks
    self.bookmarkGroups = bookmarkGroups
    self.manualUpdate = manualUpdate
    if let bookmark = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
      self._bookmarkTitle = State(initialValue: bookmark.title)
      if let parentId = bookmark.parent?.id {
        self._selectId = State(initialValue: parentId)
      }
    } else {
      self._bookmarkTitle = State(initialValue: tab.title)
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if let bookmark = bookmarks.first(where: { $0.url == tab.originURL.absoluteString }) {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Text(NSLocalizedString("Name", comment: ""))
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
                .font(.system(size: 13))
            }
            .frame(width: 160, height: 20)
          }
          .padding(.bottom, 7)
          HStack(spacing: 0) {
            Text(NSLocalizedString("Folder", comment: ""))
            Spacer()
            Picker("", selection: $selectId) {
              Text("----").tag(UUID?.none)
              ForEach(bookmarkGroups, id: \.id) { target in
                Text(target.title).tag(target.id as UUID?)
              }
            }
            .frame(width: 168)
          }
          .padding(.bottom, 10)
          HStack(spacing: 0) {
            Button(NSLocalizedString("Save", comment: "")) {
              if bookmarkTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
              }
              
              BookmarkAPI.deleteBookmark(bookmarks: bookmarks, bookmark: bookmark)
              
              if let bookmarkId = selectId, let target = bookmarkGroups.first(where: { $0.id == bookmarkId }), let children = target.children {
                let index = children.filter({ childBookmark in
                  BookmarkAPI.isBookmarkGroup(childBookmark) == false
                }).count
                BookmarkAPI.addBookmark(index: index, parent: target, title: bookmarkTitle, url: tab.originURL.absoluteString, favicon: tab.faviconData)
                target.isOpen = true
              } else {
                let index = bookmarks.filter({ childBookmark in
                  BookmarkAPI.isBookmarkGroup(childBookmark) == false
                }).count
                BookmarkAPI.addBookmark(index: index, title: bookmarkTitle, url: tab.originURL.absoluteString, favicon: tab.faviconData)
              }
              
              manualUpdate.bookmarks = !manualUpdate.bookmarks
              self.onClose()
            }
            .buttonStyle(DialogButtonStyle())
          }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
      } else {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Text(NSLocalizedString("Name", comment: ""))
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
                .font(.system(size: 13))
            }
            .frame(width: 160, height: 20)
          }
          .padding(.bottom, 7)
          HStack(spacing: 0) {
            Text(NSLocalizedString("Folder", comment: ""))
            Spacer()
            Picker("", selection: $selectId) {
              Text("----").tag(UUID?.none)
              ForEach(bookmarkGroups, id: \.id) { target in
                Text(target.title).tag(target.id as UUID?)
              }
            }
            .frame(width: 168)
          }
          .padding(.bottom, 10)
          HStack(spacing: 0) {
            Button(NSLocalizedString("Save", comment: "")) {
              if bookmarkTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
              }
              
              if let bookmarkId = selectId, let target = bookmarkGroups.first(where: { $0.id == bookmarkId }), let children = target.children {
                let index = children.filter({ childBookmark in
                  BookmarkAPI.isBookmarkGroup(childBookmark) == false
                }).count
                BookmarkAPI.addBookmark(index: index, parent: target, title: bookmarkTitle, url: tab.originURL.absoluteString, favicon: tab.faviconData)
                target.isOpen = true
              } else {
                let index = bookmarks.filter({ childBookmark in
                  BookmarkAPI.isBookmarkGroup(childBookmark) == false
                }).count
                BookmarkAPI.addBookmark(index: index, title: bookmarkTitle, url: tab.originURL.absoluteString, favicon: tab.faviconData)
              }
              
              manualUpdate.bookmarks = !manualUpdate.bookmarks
              self.onClose()
            }
            .buttonStyle(DialogButtonStyle())
          }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
      }
    }
    .frame(width: 260)
  }
}
