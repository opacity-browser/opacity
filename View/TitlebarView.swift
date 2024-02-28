//
//  TitlebarView.swift
//  Opacity
//
//  Created by Falsy on 1/15/24.
//

import SwiftUI

struct TitlebarView: View {
  @Environment(\.colorScheme) var colorScheme

  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  
  @State var tabWidth: CGFloat = 220
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          ZStack {
            TabAreaNSView(service: service, tabs: $tabs, activeTabId: $activeTabId)
            
            HStack(spacing: 0) {
              
              VStack(spacing: 0) { }.frame(width: 74)
              
              HStack(spacing: 0) {
                HStack(spacing: 0) {
                  ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    if Int(geometry.size.width / 60) > index {
                      BrowserTabView(service: service, browser: browser, tabs: $tabs, tab: tab, activeTabId: $activeTabId, index: index, tabWidth: $tabWidth) {
                        tabs.remove(at: index)
                        if tabs.count == 0 {
                          AppDelegate.shared.closeWindow()
                        } else {
                          let targetIndex = tabs.count > index ? index : tabs.count - 1
                          activeTabId = tabs[targetIndex].id
                        }
                      }
                      .contentShape(Rectangle())
                    }
                  }
                }
                .onAppear {
                  activeTabId = tabs[0].id
                }
                
                Button(action: {
                  if let keyWindow = NSApplication.shared.keyWindow {
                    let windowNumber = keyWindow.windowNumber
                    if let target = self.service.browsers[windowNumber] {
                      target.initTab()
                    }
                  }
                }) {
                  Image(systemName: "plus")
                    .font(.system(size: 11))
                    .frame(maxWidth: 24, maxHeight: 24)
                    .background(isAddHover ? .gray.opacity(0.2) : .gray.opacity(0))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.top, 1)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .onHover { isHover in
                  withAnimation {
                    isAddHover = isHover
                  }
                }
              }
              .frame(width: geometry.size.width - 150, alignment: .leading)
              
              VStack(spacing: 0) { }
                .frame(width: 42)
            }
            .frame(maxWidth: .infinity, maxHeight: 38, alignment: .leading)
            .background(Color("TabBackground"))
          }
          
          Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 4)
            .foregroundColor(Color("MainBlack"))
          
          // search area
          if let activeTab = tabs.first(where: { $0.id == activeTabId }) {
            SearchView(tab: activeTab)
              .frame(maxWidth: .infinity,  maxHeight: 41)
              .background(Color("MainBlack"))
          }
        }
      }
    }
    .frame(height: 80)
  }
}
