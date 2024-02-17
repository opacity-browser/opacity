//
//  ForwardKeyButton.swift
//  FriedEgg
//
//  Created by Falsy on 2/17/24.
//

import SwiftUI

struct ForwardKeyButton: View {
  @ObservedObject var tab: Tab
  
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  
  @State private var isForwardHober: Bool = false
  
  var body: some View {
    VStack {
      VStack(spacing: 0) {
        Image(systemName: "chevron.forward")
          .foregroundColor(Color("Icon"))
          .fontWeight(.regular)
          .font(.system(size: 14))
          .opacity(tab.isForward ? 1 : 0.4)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isForwardHober && tab.isForward ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isForwardHober = hovering
        }
      }
    }
    .frame(width: iconHeight, height: iconHeight)
  }
}
