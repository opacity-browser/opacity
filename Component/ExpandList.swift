//
//  DisclosureGroupView.swift
//  Opacity
//
//  Created by Falsy on 1/9/24.
//

import SwiftUI

struct ExpandList<Title: View, Content: View>: View {
  @State private var isExpanded: Bool = true
  let title: () -> Title
  let content: () -> Content

  init(@ViewBuilder title: @escaping () -> Title, @ViewBuilder content: @escaping () -> Content) {
      self.title = title
      self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      Button(action: {
        isExpanded.toggle()
      }) {
        HStack(spacing: 0) {
          Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
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
      .padding(0)
      .padding(.leading, 10)
      .padding(.bottom, 2)
      .buttonStyle(PlainButtonStyle())

      if isExpanded {
        content()
      }
    }
    .frame(maxWidth: .infinity)
  }
}
