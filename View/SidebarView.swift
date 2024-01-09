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
      VStack { }.frame(maxHeight: 36)
      Divider()
      VStack { }.frame(maxHeight: 26)
      Divider()
      BookmarkView()
        .padding(.top, 10)
      Spacer()
    }
    .ignoresSafeArea(.all, edges: .all)
  }
}

#Preview {
    SidebarView()
}
