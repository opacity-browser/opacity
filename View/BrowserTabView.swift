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
  @Binding var showProgress: Bool
  var onClose: () -> Void
  
  @State private var isTabHover: Bool = false
  @State private var isCloseHover: Bool = false
  @State private var loadingAnimation: Bool = false
  
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
            
            if let favicon = tab.favicon {
              VStack(spacing: 0) {
                favicon
                  .resizable() // 이미지 크기 조절 가능하게 함
                  .aspectRatio(contentMode: .fill)
                  .frame(maxWidth: 14, maxHeight: 14)
                  .clipShape(RoundedRectangle(cornerRadius: 4))
                  .clipped()
              }
              .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
              .padding(.leading, 8)
            } else if showProgress {
              VStack(spacing: 0) {
                Circle()
                  .trim(from: 0, to: 0.7) // 원을 부분적으로 그리기
                  .stroke(Color("PointJade").opacity(0.5), lineWidth: 2) // 선의 색상과 두께
                  .frame(maxWidth: 12, maxHeight: 12, alignment: .center)
                  .rotationEffect(Angle(degrees: loadingAnimation ? 360 : 0))
                  .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: loadingAnimation)
                  .onAppear {
                    self.loadingAnimation = true
                  }
              }
              .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
              .padding(.leading, 8)
            } else {
              VStack(spacing: 0) { }
                .frame(width: 4)
            }
            
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
            .onHover { hovering in
              isCloseHover = hovering
            }
          }
          .frame(maxWidth: 220, maxHeight: 30, alignment: .leading)
          .padding(.top, 2)
        }
        .frame(maxWidth: 220, alignment: .leading)
        .padding(.horizontal, 6)
      }
      .frame(maxWidth: 220)
      .onHover { hovering in
        withAnimation {
          isTabHover = hovering
        }
      }
      .frame(height: 36)
    }
    .frame(maxWidth: 220, maxHeight: 36)
    .onChange(of: showProgress) { oldValue, newValue in
      if newValue == false {
        loadingAnimation = false
      }
    }
  }
}

