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
  
  @ObservedObject var browser: Browser
  @State var isCloseHover: Bool = false
  
  var body: some View {
    ScrollView {
      HStack(spacing: 0) {
        Rectangle()
          .frame(maxWidth: 1, maxHeight: .infinity)
          .foregroundColor(Color("UIBorder"))
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Text(NSLocalizedString("Bookmark", comment: ""))
              .font(.system(size: 14))
              .foregroundColor(Color("UIText"))
            
            Spacer()
            
            VStack(spacing: 0) {
              Image(systemName: "xmark")
                .rotationEffect(.degrees(90))
                .foregroundColor(Color("Icon"))
                .font(.system(size: 13))
                .fontWeight(.regular)
            }
            .frame(maxWidth: 25, maxHeight: 25)
            .background(isCloseHover ? .gray.opacity(0.2) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .offset(x: 5)
            .onHover { hovering in
              withAnimation {
                isCloseHover = hovering
              }
            }
            .onTapGesture {
              browser.isSideBar = false
            }
          }
          
          
          BookmarkList()
//          BookmarkList()
          
          Spacer()
          
          Divider()
          
//          ForEach(allBookmarks) { test in
//            Text(test.title)
//          }
          
          Divider()
        }
        .padding(20)
      }
    }
    .frame(width: 300, alignment: .leading)
    .background(Color("SearchBarBG"))
    .contextMenu {
      Button(NSLocalizedString("Add Folder", comment: "")) {
        let newBookmark = Bookmark()
        modelContext.insert(newBookmark)
        do {
          try modelContext.save()
        } catch {
          print("basic bookmark insert error")
        }
      }
        .frame(width: 200)
    }
  }
}
