//
//  SideBarView.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

struct SideBarView: View {
  @Environment(\.modelContext) var modelContext
  @Query(filter: #Predicate<Bookmark> {
    $0.parent == nil
  }) var bookmarks: [Bookmark]
  
  @ObservedObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate
  @State var isCloseHover: Bool = false
  
  var body: some View {
    HStack(spacing: 0) {
      Rectangle()
        .frame(maxWidth: 1, maxHeight: .infinity)
        .foregroundColor(Color("UIBorder"))
      ScrollView {
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            HStack(spacing: 0) {
              Text(NSLocalizedString("Bookmark", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(Color("UIText"))
                .padding(.leading, 10)
              
              Spacer()
              
              VStack(spacing: 0) {
                Image(systemName: "xmark")
                  .foregroundColor(Color("Icon"))
                  .font(.system(size: 13))
                  .fontWeight(.regular)
              }
              .frame(maxWidth: 25, maxHeight: 25)
              .background(isCloseHover ? .gray.opacity(0.2) : .gray.opacity(0))
              .clipShape(RoundedRectangle(cornerRadius: 6))
              .onHover { hovering in
                withAnimation {
                  isCloseHover = hovering
                }
              }
              .onTapGesture {
                browser.isSideBar = false
              }
            }
            .frame(height: 25)
            .padding(.vertical, 5)
            
            BookmarkList(browser: browser, manualUpdate: manualUpdate, bookmarks: bookmarks)
            
            Spacer()
            
            ForEach(bookmarks) { book in
              VStack {
                Text(book.title)
                Text(book.parent?.title ?? "none")
                Text("\(book.index)")
              }
            }
            
          }
          .padding(.trailing, 10)
          .padding(.vertical, 10)
          .padding(.leading, 5)
        }
      }
      .background(Color("SearchBarBG"))
      .contextMenu {
        Button(NSLocalizedString("Add Folder", comment: "")) {
          do {
            let newBookmark = Bookmark(index: bookmarks.count)
            modelContext.insert(newBookmark)
            try modelContext.save()
          } catch {
            print("basic bookmark insert error")
          }
        }
      }
      .onAppear {
        if bookmarks.count == 0 {
          do {
            let newBookmark = Bookmark(index: 0)
            modelContext.insert(newBookmark)
            try modelContext.save()
          } catch {
            print("init bookmark insert error")
          }
        }
      }
    }
    .frame(maxWidth: 320, maxHeight: .infinity)
  }
}
