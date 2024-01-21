//
//  BrowserTabView.swift
//  Opacity
//
//  Created by Falsy on 1/11/24.
//

import SwiftUI

struct BrowserTabView: View {
  @ObservedObject var tab: Tab
  var isActive: Bool
  var onClose: () -> Void
  
  @State private var isTabHover: Bool = false
  @State private var isCloseHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        if isActive {
          Rectangle()
            .frame(maxWidth: 220, maxHeight: 32, alignment: .leading)
            .foregroundColor(Color("MainBlack"))
            .clipShape((BrowserTabShape(cornerRadius: 10)))
            .offset(y: 3)
        }
        ZStack {
          if !isActive && isTabHover {
            Rectangle()
              .frame(maxWidth: 220, maxHeight: 26, alignment: .leading)
              .foregroundColor(Color("PointJade").opacity(0.2))
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .offset(y: 1)
          }
          
          HStack(spacing: 0) {
            
            VStack(spacing: 0) {
              tab.favicon
                .resizable() // 이미지 크기 조절 가능하게 함
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 14, maxHeight: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .clipped()
            }
            .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
            .padding(.leading, 7)
            
            Text(tab.title)
              .frame(maxWidth: 160, maxHeight: 22, alignment: .leading)
              .foregroundColor(isActive || isTabHover ? .white : .white.opacity(0.6))
              .font(.system(size: 11))
              .padding(.leading, 5)
              .padding(.trailing, 5)
              .lineLimit(1)
              .truncationMode(.tail)
            
            Button {
              onClose()
            } label: {
              ZStack {
                if isCloseHover {
                  Rectangle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isActive ? .gray.opacity(0.2) : .black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Image(systemName: "xmark")
                  .frame(width: 18, height: 18)
                  .font(.system(size: 9))
                  .fontWeight(.medium)
                  .opacity(isCloseHover ? 1 : 0.6)
              }
            }
            .buttonStyle(.plain)
            .frame(width: 30, height: 22)
//            .contentShape(Rectangle())
            .onHover { hovering in
                isCloseHover = hovering
            }
//            .background(.red.opacity(0.2))
//            .padding(.leading, 5)
//            .padding(.trailing, 15)
          }
          .frame(maxWidth: 220, maxHeight: 30, alignment: .leading)
          .padding(.top, 2)
//          .frame(maxWidth: 180, maxHeight: 22)
//          .background(.green.opacity(0.2))
//          .offset(y: 5)
        }
        .frame(maxWidth: 220, alignment: .leading)
        .padding(.horizontal, 6)
      }
      .frame(maxWidth: 220)
//      .background(.red.opacity(0.2))
      .onHover { hovering in
        withAnimation {
          isTabHover = hovering
        }
      }
      .frame(height: 36)
    }
    .frame(maxWidth: 220, maxHeight: 36)
//    .frame(height: 36)
//    .background(.red.opacity(0.2))
//    .offset(x: CGFloat(index * -15))
//    .frame(maxWidth: 160, maxHeight: 34, alignment: .leading)
//    .background(isActive ? Color(red: 30/255, green: 30/255, blue: 30/255) : .black.opacity(0))
//    .offset(y: 5)
//    .clipShape((BrowserTabShape(cornerRadius: 15)))
  }
}

