//
//  DisclosureGroupView.swift
//  Opacity
//
//  Created by Falsy on 1/9/24.
//

import SwiftUI

struct ExpandList<bookmark: Bookmark, Title: View, Content: View>: View {
  var bookmark: Bookmark
  let title: () -> Title
  let content: () -> Content

  init(bookmark: Bookmark, @ViewBuilder title: @escaping () -> Title, @ViewBuilder content: @escaping () -> Content) {
    self.bookmark = bookmark
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Image(systemName: self.bookmark.isOpen ? "chevron.down" : "chevron.right")
            .font(.system(size: 9))
            .bold()
            .frame(width: 10, height: 10, alignment: .center)
            .padding(.trailing, 2)
            .opacity(0.7)
          title()
          Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.bottom, 2)
      .buttonStyle(PlainButtonStyle())
      .onTapGesture {
        self.bookmark.isOpen.toggle()
      }

      if self.bookmark.isOpen {
        content()
      }
    }
    .frame(maxWidth: .infinity)
  }
}
