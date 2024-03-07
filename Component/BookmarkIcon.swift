//
//  BookmarkIcon.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI

struct BookmarkIcon: View {
  @State private var isBookmarkHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        Image(systemName: "bookmark")
          .foregroundColor(Color("Icon"))
          .font(.system(size: 14))
          .fontWeight(.regular)
      }
      .frame(maxWidth: 24, maxHeight: 24)
      .background(isBookmarkHover ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .onHover { hovering in
        withAnimation {
          isBookmarkHover = hovering
        }
      }
    }
  }
}
