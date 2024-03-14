//
//  BookmarkTitle.swift
//  Opacity
//
//  Created by Falsy on 3/11/24.
//

import SwiftUI

struct BookmarkTitle: View {
  var bookmarks: [Bookmark]
  var bookmark: Bookmark
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  @FocusState private var isTextFieldFocused: Bool
  @State private var isEditName: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if let faviconData = bookmark.favicon, let nsImage = NSImage(data: faviconData) {
          VStack(spacing: 0) {
            Image(nsImage: nsImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(maxWidth: 14, maxHeight: 14)
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .clipped()
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.trailing, 4)
        } else {
          VStack(spacing: 0) {
            Image(systemName: "globe")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Point"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.trailing, 4)
        }
        
        if isEditName {
          TextField(NSLocalizedString("Name", comment: ""), text: Bindable(bookmark).title, onEditingChanged: { isEdit in
            if !isEdit {
              isEditName = false
            }
          })
          .frame(height: 26)
          .font(.system(size: 13))
          .focused($isTextFieldFocused)
          .textFieldStyle(.plain)
          .onSubmit {
            isTextFieldFocused = false
            isEditName = false
          }
        } else {
          VStack(spacing: 0) {
            HStack(spacing: 0) {
              Text(bookmark.title)
                .font(.system(size: 13))
                .frame(height: 26)
              Spacer()
            }
          }
          .frame(maxWidth: .infinity)
          .background(Color("SearchBarBG"))
          .onTapGesture {
            guard let url = bookmark.url else { return }
            if let activeTabId = browser.activeTabId, let thisTab = browser.tabs.first(where: { $0.id == activeTabId }), thisTab.isInit {
              thisTab.updateURLBySearch(url: URL(string: url)!)
            } else {
              browser.newTab(URL(string: url)!)
            }
          }
        }
      }
      .padding(0)
      .frame(maxWidth: .infinity)
    }
    .contextMenu {
      Button(NSLocalizedString("Change Name", comment: "")) {
        isTextFieldFocused = true
        isEditName = true
      }
      Divider()
      Button(NSLocalizedString("Delete", comment: "")) {
        BookmarkManager.deleteBookmark(bookmarks: bookmarks, bookmark: bookmark)
        manualUpdate.bookmarks = !manualUpdate.bookmarks
      }
      Divider()
      Button(NSLocalizedString("Add Folder", comment: "")) {
        if let parent = bookmark.parent, let children = parent.children {
          let index = children.filter({ target in
            target.url == nil
          }).count
          BookmarkManager.addBookmark(index: index, parent: parent)
        } else {
          let index = bookmarks.filter({ target in
            target.url == nil
          }).count
          BookmarkManager.addBookmark(index: index)
        }
        manualUpdate.bookmarks = !manualUpdate.bookmarks
      }
    }
  }
}
