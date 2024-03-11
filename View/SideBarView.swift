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
            
            BookmarkList()
            
            Spacer()
            
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
            let newBookmark = Bookmark()
            modelContext.insert(newBookmark)
            try modelContext.save()
          } catch {
            print("basic bookmark insert error")
          }
        }
      }
    }
    .frame(maxWidth: 320, maxHeight: .infinity)
  }
}
