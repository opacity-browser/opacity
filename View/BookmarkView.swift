//
//  BookmarkView.swift
//  Opacity
//
//  Created by Falsy on 1/9/24.
//

import SwiftUI

struct BookmarkView: View {  
  var body: some View {
    VStack(spacing: 0) {
      ForEach (0..<1) { i in
        ExpandList(title: {
          HStack(spacing: 0) {
            Image("icon-16")
            Text("Bookmark")
              .padding(.vertical, 2.5)
              .padding(.leading, 5)
          }
        }, content: {
          VStack(spacing: 0) {
            ExpandList(title: {
              HStack(spacing: 0) {
                Image(systemName: "folder.fill")
                  .opacity(0.6)
                  .font(.system(size: 12))
                Text("Bookmark")
                  .padding(.vertical, 2.2)
                  .padding(.leading, 4)
              }
            }, content: {
              VStack(spacing: 0) {
                HStack(spacing: 0) {
                  Image(systemName: "bookmark.circle")
                  Text("Apple")
                    .padding(.leading, 4)
                    .padding(.vertical, 3.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 35)
                
                HStack(spacing: 0) {
                  Image(systemName: "bookmark.circle")
                  Text("Microsoft")
                    .padding(.leading, 4)
                    .padding(.vertical, 3.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 35)
              }
            })
            .padding(.leading, 12)
            
            ExpandList(title: {
              HStack(spacing: 0) {
                Image(systemName: "folder.fill")
                  .opacity(0.6)
                  .font(.system(size: 12))
                Text("Bookmark")
                  .padding(.vertical, 2.2)
                  .padding(.leading, 4)
              }
            }, content: {
              VStack(spacing: 0) {
                HStack(spacing: 0) {
                  Image(systemName: "bookmark.circle")
                  Text("Apple")
                    .padding(.leading, 4)
                    .padding(.vertical, 3.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 35)
                
                HStack(spacing: 0) {
                  Image(systemName: "bookmark.circle")
                  Text("Microsoft")
                    .padding(.leading, 4)
                    .padding(.vertical, 3.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 35)
              }
            })
            .padding(.leading, 12)
            
            HStack(spacing: 0) {
              Image(systemName: "bookmark.circle")
              Text("Apple")
                .padding(.leading, 4)
                .padding(.vertical, 3.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 35)
            
            HStack(spacing: 0) {
              Image(systemName: "bookmark.circle")
              Text("Microsoft")
                .padding(.leading, 4)
                .padding(.vertical, 3.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 35)
            
            HStack(spacing: 0) {
              Image(systemName: "bookmark.circle")
              Text("Alphabet")
                .padding(.leading, 4)
                .padding(.vertical, 3.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 35)
            
            HStack(spacing: 0) {
              Image(systemName: "bookmark.circle")
              Text("Amazon")
                .padding(.leading, 4)
                .padding(.vertical, 3.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 35)
            
          }
        })
      } // forEach
    }
  }
}

#Preview {
  BookmarkView().listStyle(.sidebar)
}



//      DisclosureGroup(isExpanded: $isExpanded) {
//        VStack(spacing: 0) {
//          Label("ContentView", systemImage: "bookmark.fill")
//            .frame(maxWidth: .infinity, alignment: .leading)
//          Label("Naver", systemImage: "bookmark.square.fill")
//            .frame(maxWidth: .infinity, alignment: .leading)
//          Label("Daum", systemImage: "bookmark.square")
//            .frame(maxWidth: .infinity, alignment: .leading)
//          Label("Google", systemImage: "bookmark.circle")
//            .frame(maxWidth: .infinity, alignment: .leading)
//          Label("Github", systemImage: "bookmark.circle.fill")
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//      } label: {
//        Label {
//          Text("Bookmark")
//            .background(.red.opacity(0.2))
//            .frame(maxHeight: 5)
//        } icon: {
//          Image("icon-16")
//        }
//      }
//      .background(.blue.opacity(0.2))
//      .frame(maxWidth: .infinity, alignment: .leading)
//      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//      Spacer()
