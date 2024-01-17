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
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        if isActive {
          Rectangle()
            .frame(maxWidth: 200, maxHeight: 30, alignment: .leading)
            .foregroundColor(Color("MainBlack"))
            .clipShape((BrowserTabShape(cornerRadius: 12)))
            .offset(y: 3)
        }
        HStack(spacing: 0) {
          Text(title)
            .frame(maxWidth: 160, maxHeight: 30, alignment: .leading)
            .font(.system(size: 11))
            .padding(.trailing, 5)
            .padding(.leading, 20)
            .padding(.top, 4)
            .lineLimit(1)
            .truncationMode(.tail)
//            .background(.red.opacity(0.2))
          
          Button {
            onClose()
          } label: {
            Image(systemName: "xmark")
              .frame(maxHeight: 32)
              .font(.system(size: 10))
              .opacity(0.8)
              .padding(.top, 4)
              .padding(.horizontal, 5)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .frame(width: 10, height: 30, alignment: .trailing)
          .padding(.leading, 5)
          .padding(.trailing, 15)
//          .background(.green.opacity(0.2))
        }
        .frame(maxWidth: 200, alignment: .leading)
//        .background(.blue.opacity(0.2))
      }
    }
    .frame(maxWidth: 200, maxHeight: 32)
//    .offset(x: CGFloat(index * -15))
//    .frame(maxWidth: 160, maxHeight: 34, alignment: .leading)
//    .background(isActive ? Color(red: 30/255, green: 30/255, blue: 30/255) : .black.opacity(0))
//    .offset(y: 5)
//    .clipShape((BrowserTabShape(cornerRadius: 15)))
  }
}

