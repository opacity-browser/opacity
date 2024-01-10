//
//  TabView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct TabView: View {
  var title: String
  var isActive: Bool
  var onClick: ()-> Void
  var onClose: ()-> Void
  
  @State private var showCloseButton: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        HStack(spacing: 0) {
          if showCloseButton {
            Button {
              onClose()
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 10))
            }
            .buttonStyle(.plain)
          }
        }
        .frame(width: 10)
        .padding(.leading, 10)
        
        Text(title)
          .frame(minWidth: 20, maxWidth: 80, alignment: .leading)
          .font(.system(size: 12))
          .padding(.trailing, 5)
          .padding(.leading, 15)
        
      }
        .frame(maxHeight: 26, alignment: .leading)
      if isActive {
        Divider()
          .border(.pointBlue)
          .offset(y: 1)
      }
    }
    .frame(maxWidth: 120, maxHeight: 26, alignment: .leading)
    .onTapGesture {
      onClick()
    }
    .onHover { isHover in
      showCloseButton = isHover
    }
  }
}
