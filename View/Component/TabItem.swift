//
//  TabItem.swift
//  Opacity
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItem: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @Binding var activeTabId: UUID?
  @Binding var tabWidth: CGFloat
  
  @State var loadingAnimation: Bool = false
  @State var isTabHover: Bool = false
  
  var isActive: Bool {
    return tab.id == activeTabId
  }
  
  var isFavicon: Bool {
    return tab.isInit || tab.isSetting || (!tab.isInit && !tab.isSetting && (tab.pageProgress > 0 || tab.favicon != nil))
  }
  
  var body: some View {
    ZStack {
      ZStack {
        HStack(spacing: 0) {
          if isFavicon  {
            HStack(spacing: 0) {
              if tab.isInit || tab.isSetting {
                VStack(spacing: 0) {
                  Image("MainLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 13, maxHeight: 13)
                    .opacity(0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .clipped()
                }
                .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
              } else if tab.pageProgress > 0 {
                VStack(spacing: 0) {
                  Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color("Icon").opacity(0.5), lineWidth: 2)
                    .frame(maxWidth: 12, maxHeight: 12, alignment: .center)
                    .rotationEffect(Angle(degrees: loadingAnimation ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: loadingAnimation)
                }
                .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
              } else if let favicon = tab.favicon {
                VStack(spacing: 0) {
                  favicon
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 14, maxHeight: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .clipped()
                }
                .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
              }
            }
            .frame(maxWidth: 16, maxHeight: 16, alignment: .center)
            .padding(.leading, tabWidth > 60 ? 5 : 0)
          }
          
          if tabWidth > 60 || tab.favicon == nil {
            Text(tab.title == "" ? tab.printURL : tab.title)
              .frame(maxWidth: 200, maxHeight: 29, alignment: .leading)
              .foregroundColor(Color("UIText").opacity(isActive || isTabHover ? 1 : 0.8))
              .font(.system(size: 12))
              .padding(.leading, isFavicon ? 5 : 10)
              .padding(.trailing, 25)
              .lineLimit(1)
              .truncationMode(.tail)
          }
        }
        .opacity(tabWidth < 60 && isActive ? 0 : 1)
        .onHover { hovering in
          isTabHover = hovering
        }
        .onChange(of: tab.pageProgress) { _, nV in
          self.loadingAnimation = nV > 0
        }
      }
      .frame(height: 29)
      .offset(y: -0.5)
      .background(Color("SearchBarBG").opacity(isTabHover ? 0.7 : 0))
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 1)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}
