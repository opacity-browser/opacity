//
//  TabItem.swift
//  FriedEgg
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItem: View {
  @ObservedObject var tab: Tab
  var isActive: Bool
  @Binding var activeTabIndex: Int
  @Binding var showProgress: Bool
  @Binding var isTabHover: Bool
  @Binding var loadingAnimation: Bool
  
  var body: some View {
    ZStack {
      if let favicon = tab.favicon {
        Text(tab.title)
          .frame(maxWidth: 220, maxHeight: 28, alignment: .leading)
          .foregroundColor(isActive || isTabHover ? .white : .white.opacity(0.6))
          .font(.system(size: 12))
          .padding(.leading, 28)
          .padding(.trailing, 20)
          .lineLimit(1)
          .truncationMode(.tail)
//          .background(.blue.opacity(0.2))

        HStack(spacing: 0) {
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
          Spacer()
        }
      } else if showProgress {
        Text(tab.title)
          .frame(maxWidth: 220, maxHeight: 29, alignment: .leading)
          .foregroundColor(isActive || isTabHover ? .white : .white.opacity(0.6))
          .font(.system(size: 12))
          .padding(.leading, 28)
          .padding(.trailing, 20)
          .lineLimit(1)
          .truncationMode(.tail)
//          .background(.blue.opacity(0.2))

        HStack(spacing: 0) {
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
          Spacer()
        }
      } else {
        Text(tab.title)
          .frame(maxWidth: 220, maxHeight: 29, alignment: .leading)
          .foregroundColor(isActive || isTabHover ? .white : .white.opacity(0.6))
          .font(.system(size: 12))
          .padding(.leading, 9)
          .padding(.trailing, 20)
          .lineLimit(1)
          .truncationMode(.tail)
//          .background(.blue.opacity(0.2))
      }
    }
    .frame(height: 30)
    .background(isTabHover ? Color("MainBlack").opacity(0.3) : Color("MainBlack").opacity(0))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .offset(y: 1)
  }
}
