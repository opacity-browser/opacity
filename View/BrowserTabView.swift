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
  @Binding var activeTabId: UUID?
  var index: Int
  @Binding var tabWidth: CGFloat
  @Binding var showProgress: Bool
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
            .frame(maxWidth: 220, maxHeight: 33, alignment: .leading)
            .foregroundColor(Color("MainBlack").opacity(isActive ? 1 : 0))
            .clipShape((BrowserTabShape(cornerRadius: 10)))
            .offset(y: 3)
            .animation(.linear(duration: 0.15), value: activeTabId)
          
          ZStack {
            Button {
              
            } label: {
              TabItemView(service: service, tabs: $tabs, tab: tab, activeTabId: $activeTabId, index: index, tabWidth: $tabWidth, showProgress: $showProgress, isTabHover: $isTabHover, loadingAnimation: $loadingAnimation)
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
          }
          .frame(maxWidth: 220, alignment: .leading)
          .padding(.horizontal, 6)
        }
        .frame(maxWidth: 220, maxHeight: 38)
        .onHover { hovering in
          isTabHover = hovering
        }
        .onChange(of: geometry.size) { _, newValue in
          tabWidth = newValue.width
        }
      }
      .frame(maxWidth: 220, maxHeight: 38)
      .onChange(of: showProgress) { _, newValue in
        if newValue == false {
          loadingAnimation = false
        }
      }
      .onChange(of: tab.pageProgress) { _, newValue in
        print("change page progress: \(newValue)")
        if newValue == 1.0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.15)) {
              showProgress = false
            }
            tab.pageProgress = 0.0
          }
        } else if newValue > 0.0 && newValue < 1.0 {
          showProgress = true
        }
      }
    }
  }
}

