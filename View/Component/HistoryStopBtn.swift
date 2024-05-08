//
//  HistoryStopBtn.swift
//  Opacity
//
//  Created by Falsy on 5/8/24.
//

import SwiftUI

struct HistoryStopBtn: View {
  @ObservedObject var tab: Tab
  let iconHeight: CGFloat
  let iconRadius: CGFloat
  
  @State private var isStopHober: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "xmark")
        .foregroundColor(Color("Icon"))
        .font(.system(size: 13.5))
        .fontWeight(.regular)
        .offset(y: -0.5)
    }
    .frame(maxWidth: iconHeight, maxHeight: iconHeight)
    .background(isStopHober ? .gray.opacity(0.2) : .gray.opacity(0))
    .clipShape(RoundedRectangle(cornerRadius: iconRadius))
    .onHover { hovering in
      withAnimation {
        isStopHober = hovering
      }
    }
    .onTapGesture {
      DispatchQueue.main.async {
        tab.stopProcess = true
      }
    }
  }
}
