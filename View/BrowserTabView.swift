//
//  BrowserTabView.swift
//  Opacity
//
//  Created by Falsy on 1/11/24.
//

import SwiftUI

struct StaticColorButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .opacity(1) // 클릭 시 투명도 변화 없음
  }
}

struct BrowserTabView: View {
  @ObservedObject var service: Service
  @Binding var tabs: [Tab]
  @ObservedObject var tab: Tab
  var isActive: Bool
  @Binding var activeTabId: UUID?
  var index: Int
  @Binding var showProgress: Bool
  var onClose: () -> Void
  
  @State var isTabHover: Bool = false
  @State var loadingAnimation: Bool = false
  @State private var isCloseHover: Bool = false

  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Rectangle()
          .frame(maxWidth: 220, maxHeight: 34, alignment: .leading)
          .foregroundColor(Color("MainBlack").opacity(isActive ? 1 : 0))
          .clipShape((BrowserTabShape(cornerRadius: 10)))
          .offset(y: 3)
          .animation(.linear(duration: 0.15), value: activeTabId)
        
        ZStack {
          Button {
            
          } label: {
            TabItemView(service: service, tabs: $tabs, tab: tab, isActive: isActive, activeTabId: $activeTabId, index: index, showProgress: $showProgress, isTabHover: $isTabHover, loadingAnimation: $loadingAnimation)
//            TabItem(tab: tab, isActive: isActive, activeTabIndex: $activeTabIndex, showProgress: $showProgress, isTabHover: $isTabHover, loadingAnimation: $loadingAnimation)
          }
          .buttonStyle(StaticColorButtonStyle())
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .offset(y: 1)
          
          HStack(spacing: 0) {
            Spacer()
            
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
            .offset(y: 1)
          }
        }
//        .offset(y: 1)
        .frame(maxWidth: 220, alignment: .leading)
        .padding(.horizontal, 6)
      }
      .frame(maxWidth: 220, maxHeight: 36)
      .onHover { hovering in
        isTabHover = hovering
      }
    }
    .frame(maxWidth: 220, maxHeight: 36)
    .onChange(of: showProgress) { oldValue, newValue in
      if newValue == false {
        loadingAnimation = false
      }
    }
  }
}

