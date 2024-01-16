//
//  SidebarView.swift
//  Opacity
//
//  Created by Falsy on 1/9/24.
//

import SwiftUI

struct SidebarView: View {
  var body: some View {
    VStack(spacing: 0) {
//      HStack { }.frame(maxWidth: .infinity, maxHeight: 38)
      
//      Divider()
//        .border(Color(red: 25/255, green: 25/255, blue: 25/255))
      
      VStack {
        HStack {
          Image(systemName: "bookmark.fill")
            .foregroundColor(.accentColor)
            .padding(.leading, 12)
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 36, alignment: .leading)
//        .background(Color(red: 37/255, green: 37/255, blue: 37/255))
      }
      
      Divider()
      BookmarkView()
        .padding(.top, 10)
      Spacer()
    }
    .ignoresSafeArea(.container, edges: .top)
  }
}
