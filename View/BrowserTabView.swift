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
  @ObservedObject var browser: Browser
  @Binding var tabs: [Tab]
  @ObservedObject var tab: Tab
  @Binding var activeTabId: UUID?
  var index: Int
  @Binding var tabWidth: CGFloat
  var onClose: () -> Void
  
  @State var isTabHover: Bool = false
  @State var loadingAnimation: Bool = false
  @State private var isCloseHover: Bool = false
  
  var isActive: Bool {
    return tab.id == activeTabId
  }
  
  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        ZStack {
          Rectangle()
            .frame(maxWidth: 220, maxHeight: 34, alignment: .leading)
            .foregroundColor(Color("UIBorder").opacity(isActive ? 1 : 0))
//            .foregroundColor(.red)
            .clipShape((BrowserTabShape(cornerRadius: 10)))
            .offset(y: 2)
            .animation(.linear(duration: 0.15), value: activeTabId)
          Rectangle()
            .frame(maxWidth: 218.4, maxHeight: 34, alignment: .leading)
            .foregroundColor(Color("SearchBarBG").opacity(isActive ? 1 : 0))
//            .foregroundColor(.blue)
            .clipShape((BrowserTabShape(cornerRadius: 9.8)))
            .offset(y: 2.8)
            .animation(.linear(duration: 0.15), value: activeTabId)
          
          ZStack {
            Button {
            
            } label: {
              TabItemNSView(service: service, browser: browser, tabs: $tabs, tab: tab, activeTabId: $activeTabId, index: index, tabWidth: $tabWidth, loadingAnimation: $loadingAnimation)
                .frame(maxWidth: 218)
            }
            .buttonStyle(StaticColorButtonStyle())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .offset(y: 1)
            
            if tabWidth > 60 || isActive {
              HStack(spacing: 0) {
                if !(tabWidth <= 60 && isActive) {
                  Spacer()
                }
                
                Button {
                  onClose()
                } label: {
                  ZStack {
                    if isCloseHover {
                      Rectangle()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Image(systemName: "xmark")
                      .frame(width: 18, height: 18)
                      .font(.system(size: 9))
                      .fontWeight(.medium)
                      .opacity(isCloseHover ? 1 : 0.8)
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
          }
          .frame(maxWidth: 220, alignment: .leading)
          .padding(.horizontal, 6)
        }
        .frame(maxWidth: 220, maxHeight: 38)
        .onChange(of: geometry.size) { _, newValue in
          tabWidth = newValue.width
        }
      }
      .frame(maxWidth: 220, maxHeight: 38)
      .onChange(of: tab.isPageProgress) { _, newValue in
        if newValue == false {
          DispatchQueue.main.async {
            loadingAnimation = false
          }
        }
      }
      .onChange(of: tab.pageProgress) { _, newValue in
        if newValue == 1.0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tab.isPageProgress = false
            tab.pageProgress = 0.0
          }
        } else if newValue > 0.0 && newValue < 1.0 {
          DispatchQueue.main.async {
            tab.isPageProgress = true
          }
        }
      }
    }
  }
}

