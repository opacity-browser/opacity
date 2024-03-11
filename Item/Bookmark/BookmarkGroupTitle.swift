//
//  BookmarkGroupName.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI

struct BookmarkGroupTitle: View {
  @Environment(\.modelContext) var modelContext
  
  var bookmark: Bookmark
  @ObservedObject var manualUpdate: ManualUpdate
  @FocusState private var isTextFieldFocused: Bool
  @State private var isEditName: Bool = false
  
  func deleteBookmark(_ target: Bookmark) {
    if let childBookmark = target.children {
      for childTarget in childBookmark {
        deleteBookmark(childTarget)
      }
      modelContext.delete(target)
    }
  }
  
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
        do {
          deleteBookmark(bookmark)
          try modelContext.save()
          manualUpdate.bookmarks = !manualUpdate.bookmarks
        } catch {
          print("delete error")
        }
      }
      Divider()
      Button(NSLocalizedString("Add Folder", comment: "")) {
        let newBookmark = Bookmark(parent: bookmark)
        if let _ = bookmark.children {
          bookmark.children?.append(newBookmark)
          bookmark.isOpen = true
        }
      }
    }
  }
}
