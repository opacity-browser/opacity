//
//  BrowserTabView.swift
//  Opacity
//
//  Created by Falsy on 1/11/24.
//

import SwiftUI

struct BrowserTabView: View {
  @Binding var title: String
  var isActive: Bool
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
          .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
          .font(.system(size: 12))
          .padding(.trailing, 5)
          .padding(.leading, 15)
      }
        .frame(maxHeight: 26, alignment: .leading)
        .padding(.top, isActive ? 2 : 0)
      if isActive {
        Rectangle()
          .fill(.pointBlue)
          .frame(height: 2)
          .offset(y: 1)
      }
    }
    .frame(maxWidth: 160, maxHeight: 26, alignment: .leading)
    .onHover { isHover in
      showCloseButton = isHover
    }
  }
}

