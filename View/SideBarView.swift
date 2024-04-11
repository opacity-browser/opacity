//
//  SideBarView.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

struct SideBarView: View {
//  @Environment(\.modelContext) var modelContext
  @Query var bookmarks: [Bookmark]
//  @Query(filter: #Predicate<BookmarkGroup> {
//    $0.isBase == true
//  }) var baseBookmarkGroup: [BookmarkGroup]
  
//  @Query var searchHistoryGroup: [SearchHistoryGroup]
//  @Query var searchHistory: [SearchHistory]

//  @Query var visitHistoryGroup: [VisitHistoryGroup]
//  @Query var visitHistory: [VisitHistory]
  
//  @Query var books: [Bookmark]
  
  @ObservedObject var browser: Browser
  @State var isCloseHover: Bool = false
  @State var searchText: String = ""
  
  var body: some View {
    HStack(spacing: 0) {
      Rectangle()
        .frame(maxWidth: 0.5, maxHeight: .infinity)
        .foregroundColor(Color("UIBorder"))

      ScrollView {
//        ForEach(books) { book in
//          VStack {
//            HStack {
//              Text(book.title)
//            }
//          }
//          .padding(5)
//          .background(.blue.opacity(0.2))
//        }

//        ForEach(visitHistory) { sh in
//          VStack {
//            HStack {
//              Text(sh.title)
//                .onTapGesture {
//                  do {
//                    modelContext.delete(sh)
//                    try modelContext.save()
//                  } catch {
//
//                  }
//                }
//              Text("\(sh.createDate)")
//            }
//          }
//          .padding(5)
//          .background(.blue.opacity(0.2))
//        }
        
//        ForEach(visitHistoryGroup) { vhg in
//          VStack {
//            Text("\(vhg.url)-\(vhg.title)-\(vhg.updateDate)")
//            Image(nsImage: NSImage(data: vhg.faviconData!)!)
//            if let hitories = vhg.visitHistories, hitories.count > 0 {
//              Divider()
//              ForEach(hitories) { sh in
//                Text("\(sh.id)")
//              }
//            }
//          }
//          .padding(5)
//          .background(.red.opacity(0.2))
//        }
        
//        ForEach(searchHistoryGroup) { shg in
//          VStack {
//            Text(shg.searchText)
//            Text("\(shg.updateDate)")
//            if let hitories = shg.searchHistories, hitories.count > 0 {
//              Divider()
//              ForEach(hitories) { sh in
//                Text("\(sh.id)")
//              }
//            }
//          }
//          .padding(5)
//          .background(.red.opacity(0.2))
//        }

//        ForEach(searchHistory) { sh in
//          VStack {
//            HStack {
//              Text(sh.searchText)
//                .onTapGesture {
//                  do {
//                    modelContext.delete(sh)
//                    try modelContext.save()
//                  } catch {
//                    
//                  }
//                }
//              Text("\(sh.createDate)")
//            }
//          }
//          .padding(5)
//          .background(.blue.opacity(0.2))
//        }
//        
//        Button("Update") {
//          manualUpdate.bookmarks = !manualUpdate.bookmarks
//        }

        HStack(spacing: 0) {
          VStack(spacing: 0) {
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                Text(NSLocalizedString("Bookmark", comment: ""))
                  .font(.system(size: 15))
                  .foregroundColor(Color("UIText"))
                
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
                .offset(x: 5)
              }
              .frame(height: 25)
              .padding(.vertical, 8)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)

            BookmarkSearch(searchText: $searchText)
              .padding(.horizontal, 15)
              .padding(.bottom, 15)

            Rectangle()
              .frame(maxWidth: .infinity, maxHeight: 0.5)
              .foregroundColor(Color("UIBorder"))
            
            if searchText == "" {
              BookmarkList(browser: browser)
                .padding(.vertical, 10)
                .padding(.leading, 5)
                .padding(.trailing, 15)
            } else {
              BookmarkSearchList(browser: browser, bookmarks: bookmarks, searchText: $searchText)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
            
            Spacer()
          }
        }
      }
      .background(Color("SearchBarBG"))
      .contextMenu {
        Button(NSLocalizedString("Add Folder", comment: "")) {
          if let baseBookmarkGroup = BookmarkManager.getBaseBookmarkGroup() {
            BookmarkManager.addBookmarkGroup(parentGroup: baseBookmarkGroup)
          }
        }
      }
    }
    .frame(maxWidth: 280, maxHeight: .infinity)
  }
}
