//
//  SwiftUIView.swift
//  Opacity
//
//  Created by Falsy on 2/18/24.
//

import SwiftUI

struct HistoryKeyButton: View {
  @ObservedObject var tab: Tab
  var isBack: Bool
  
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  
  @State private var isBackForwardHover: Bool = false
  
  var body: some View {
    
    let icon = isBack ? "chevron.backward" : "chevron.forward"
    let isBackForward = isBack ? tab.isBack : tab.isForward
    
    VStack {
      VStack(spacing: 0) {
        Image(systemName: icon)
          .foregroundColor(Color("Icon"))
          .fontWeight(.regular)
          .font(.system(size: 14))
          .opacity(isBackForward ? 1 : 0.4)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isBackForwardHover && isBackForward ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isBackForwardHover = hovering
        }
      }
    }
    .frame(width: iconHeight, height: iconHeight)
  }
}
