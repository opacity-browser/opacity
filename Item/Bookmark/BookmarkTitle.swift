//
//  BookmarkTitle.swift
//  Opacity
//
//  Created by Falsy on 3/11/24.
//

import SwiftUI

struct BookmarkTitle: View {
  @Environment(\.modelContext) var modelContext
  var bookmarks: [Bookmark]
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
    }
    modelContext.delete(target)
  }
  
  func indexReSetting(_ parentTarget: Bookmark? = nil) {
    if let target = parentTarget, let parentTargetChildren = target.children {
      let cache = parentTargetChildren.sorted {
        return $0.index < $1.index
      }
      
      for (index, _) in cache.enumerated() {
        cache[index].index = index
      }
      
      for child in target.children! {
        let index = cache.first(where: { $0.url == child.url })!.index
        child.index = index
      }
    } else {
      let cache = bookmarks.filter({ target in
        target.url != nil && target.url != bookmark.url
      }).sorted {
        return $0.index < $1.index
      }
      
      for (index, test) in cache.enumerated() {
        cache[index].index = index
        print(test.title)
        print(test.index)
      }
      
      for child in bookmarks {
        if let cacheData = cache.first(where: { $0.url == child.url }) {
          child.index = cacheData.index
        }
      }
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
              Text(" \(bookmark.index)")
              Text(" \(bookmark.parent?.title ?? "none")")
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
        do {
          if let parentTarget = bookmark.parent {
            deleteBookmark(bookmark)
            try modelContext.save()
            indexReSetting(parentTarget)
          } else {
            deleteBookmark(bookmark)
            try modelContext.save()
            indexReSetting()
          }
          manualUpdate.bookmarks = !manualUpdate.bookmarks
        } catch {
          print("delete error")
        }
      }
      Divider()
      Button(NSLocalizedString("Add Folder", comment: "")) {
//        let newBookmark = Bookmark(index: bookmark.parent ? bookmark.parent?.children.count : bookmark.count)
//        if let parent = bookmark.parent {
//          newBookmark.parent = parent
//        }
//        do {
//          modelContext.insert(newBookmark)
//          try modelContext.save()
//          manualUpdate.bookmarks = !manualUpdate.bookmarks
//        } catch {
//          print("basic bookmark insert error")
//        }
      }
    }
  }
}
