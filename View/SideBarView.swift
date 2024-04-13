//
//  SideBarView.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

struct SideBarView: View {
  @Query var bookmarks: [Bookmark]
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @State var isCloseHover: Bool = false
  @State var searchText: String = ""
  
  var body: some View {
    HStack(spacing: 0) {
      Rectangle()
        .frame(maxWidth: 0.5, maxHeight: .infinity)
        .foregroundColor(Color("UIBorder"))
      ScrollView {
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
              BookmarkList(service: service, browser: browser)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 10)
                .padding(.leading, 5)
                .padding(.trailing, 15)
              BookmarkDragAreaNSView(service: service)
            } else {
              BookmarkSearchList(service: service, browser: browser, bookmarks: bookmarks, searchText: $searchText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
            
            Spacer()
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
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
