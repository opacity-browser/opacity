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
  var onClose: () -> Void
  
  @State private var showCloseButton: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(title)
          .frame(minWidth: 100, maxWidth: 160, alignment: .leading)
          .font(.system(size: 13))
          .padding(.trailing, 5)
          .padding(.leading, 15)
          .background(.red)
        
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
      }
      .frame(maxHeight: 24, alignment: .leading)
      .padding(.top, 4)
    }
    .frame(maxWidth: 160, maxHeight: 28, alignment: .leading)
    .onHover { isHover in
      showCloseButton = isHover
    }
    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
  }
}

