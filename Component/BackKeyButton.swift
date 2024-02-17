//
//  SwiftUIView.swift
//  FriedEgg
//
//  Created by Falsy on 2/16/24.
//

import SwiftUI

struct BackKeyButton: View {
  @ObservedObject var tab: Tab
  
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  
  @State private var isBackHover: Bool = false
  
  var body: some View {
    VStack {
      VStack(spacing: 0) {
        Image(systemName: "chevron.backward")
          .foregroundColor(Color("Icon"))
          .fontWeight(.regular)
          .font(.system(size: 14))
          .opacity(tab.isBack ? 1 : 0.4)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isBackHover && tab.isBack ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isBackHover = hovering
        }
      }
    }
    .frame(width: iconHeight, height: iconHeight)
  }
}
