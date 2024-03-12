//
//  BookmarkGroupName.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI

struct BookmarkGroupTitle: View {
  @Environment(\.modelContext) var modelContext
  
  var bookmarks: [Bookmark]
  var bookmark: Bookmark
  @ObservedObject var manualUpdate: ManualUpdate
  @FocusState private var isTextFieldFocused: Bool
  @State private var isEditName: Bool = false
  
//  func indexReSetting(_ target: Bookmark) {
//    guard let targetParentChildren = target.parent?.children else { return }
//    target.parent?.children = targetParentChildren.sorted {
//      return $0.index > $1.index
//    }
//    for (index, _) in targetParentChildren.enumerated() {
//      target.parent?.children![index].index = index
//    }
//  }
//  
//  func deleteBookmark(_ target: Bookmark) {
//    if let childBookmark = target.children {
//      for childTarget in childBookmark {
//        deleteBookmark(childTarget)
//      }
//      modelContext.delete(target)
//    }
//  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "folder")
            .foregroundColor(Color("Icon"))
            .font(.system(size: 13))
            .fontWeight(.regular)
        }
        .frame(maxWidth: 24, maxHeight: 24)
        .padding(.trailing, 2)
        
        if isEditName {
          TextField("", text: Bindable(bookmark).title, onEditingChanged: { isEdit in
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
              Text(" \(bookmark.index)")
              Text(" \(bookmark.parent?.title ?? "none")")
              Spacer()
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(0)
      .frame(maxWidth: .infinity)
      .background(Color("SearchBarBG"))
    }
    .contextMenu {
      Button(NSLocalizedString("Change Name", comment: "")) {
        isTextFieldFocused = true
        isEditName = true
      }
      Divider()
      Button(NSLocalizedString("Delete", comment: "")) {
        BookmarkAPI.deleteBookmarkGroup(bookmarks: bookmarks, bookmark: bookmark)
        manualUpdate.bookmarks = !manualUpdate.bookmarks
      }
      Divider()
      Button(NSLocalizedString("Add Folder", comment: "")) {
        if let children = bookmark.children {
          let index = children.filter({ target in
            BookmarkAPI.isBookmarkGroup(target)
          }).count
          BookmarkAPI.addBookmark(index: index, parent: bookmark)
          bookmark.isOpen = true
          manualUpdate.bookmarks = !manualUpdate.bookmarks
        }
      }
    }
  }
}
