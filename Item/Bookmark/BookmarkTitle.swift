//
//  BookmarkTitle.swift
//  Opacity
//
//  Created by Falsy on 3/11/24.
//

import SwiftUI

struct BookmarkTitle: View {
  @Environment(\.modelContext) var modelContext
  
  var bookmark: Bookmark
  @ObservedObject var browser: Browser
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
            if let url = bookmark.url {
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
        if let parent = bookmark.parent {
          let newBookmark = Bookmark(parent: parent)
          if let _ = parent.children {
            parent.children?.append(newBookmark)
          }
        } else {
          do {
            let newBookmark = Bookmark()
            modelContext.insert(newBookmark)
            try modelContext.save()
          } catch {
            print("basic bookmark insert error")
          }
        }
      }
    }
  }
}
