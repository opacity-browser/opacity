//
//  DisclosureGroupView.swift
//  Opacity
//
//  Created by Falsy on 1/9/24.
//

import SwiftUI

struct ExpandList<bookmark: Bookmark, Title: View, Content: View>: View {
  var bookmarkGroup: BookmarkGroup
  let title: () -> Title
  let content: () -> Content

  init(bookmarkGroup: BookmarkGroup, @ViewBuilder title: @escaping () -> Title, @ViewBuilder content: @escaping () -> Content) {
    self.bookmarkGroup = bookmarkGroup
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Image(systemName: self.bookmarkGroup.isOpen ? "chevron.down" : "chevron.right")
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
        self.bookmarkGroup.isOpen.toggle()
      }

      if self.bookmarkGroup.isOpen {
        content()
      }
    }
    .frame(maxWidth: .infinity)
  }
}
