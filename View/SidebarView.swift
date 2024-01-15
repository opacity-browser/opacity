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
      HStack { }.frame(maxWidth: .infinity, maxHeight: 38)
      
//      Divider()
      
      VStack {
        HStack {
          Image(systemName: "bookmark.fill")
            .foregroundColor(.accentColor)
            .padding(.leading, 12)
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 26, alignment: .leading)
      }
      
      Divider()
      BookmarkView()
        .padding(.top, 10)
      Spacer()
    }
    .ignoresSafeArea(.container, edges: .top)
  }
}
