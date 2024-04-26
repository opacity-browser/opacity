//
//  HistoryRefreshBtn.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct HistoryRefreshBtn: View {
  @State private var isRefreshHober: Bool = false
  
  let iconHeight: CGFloat
  let iconRadius: CGFloat
  
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "goforward")
        .rotationEffect(.degrees(45))
        .foregroundColor(Color("Icon"))
        .font(.system(size: 13.5))
        .fontWeight(.regular)
        .offset(y: -0.5)
    }
    .frame(maxWidth: iconHeight, maxHeight: iconHeight)
    .background(isRefreshHober ? .gray.opacity(0.2) : .gray.opacity(0))
    .clipShape(RoundedRectangle(cornerRadius: iconRadius))
    .onHover { hovering in
      withAnimation {
        isRefreshHober = hovering
      }
    }
    .onTapGesture {
      AppDelegate.shared.refreshTab()
    }
  }
}
