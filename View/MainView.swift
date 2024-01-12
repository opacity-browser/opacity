//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
  @Environment(\.colorScheme) var colorScheme
//  @ObservedObject var browser: Browser = Browser()
  @State var tabs: [Tab] = []
  @Binding var viewSize: CGSize
  @State private var isAddHover: Bool = false
  @State private var activeTabIndex: Int = -1
  
  var body: some View {
    VStack(spacing: 0) {
      // title bar area
      if(tabs.count > 0) {
        HStack {
          TitleView(
            viewSize: $viewSize,
            tab: $tabs[activeTabIndex]
          )
        }
        .frame(maxWidth: .infinity,  maxHeight: 36.0)
        .background(colorScheme == .dark ? .black.opacity(0.1) : .gray.opacity(0.5))
      }
      
      Divider()
        .border(.black.opacity(0.9))
      
      // tab bar area
      HStack(spacing: 0) {
        if tabs.count > 0 {
          ForEach(tabs.indices, id: \.self) { index in
            BrowserTabView(title: $tabs[index].title, isActive: index == activeTabIndex)
            {
              print("close")
              tabs.remove(at: index)
              activeTabIndex = tabs.count - 1
            }
            .onTapGesture {
              activeTabIndex = index
            }
            Image(systemName: "poweron")
              .frame(width: 2)
              .opacity(0.2)
          }
        }
        
        VStack {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 19, maxHeight: 19)
            .background(isAddHover ? .gray.opacity(0.1) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .padding(.leading, 5)
        .onHover { isHover in
          withAnimation {
            isAddHover = isHover
          }
        }
        .onTapGesture {
          let newTab = Tab(webURL: DEFAULT_URL)
          tabs.append(newTab)
          activeTabIndex = tabs.count - 1
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: 26, alignment: .leading)
      
      Divider()
      
      // webview area
      ZStack {
        if(tabs.count > 0) {
          ForEach(tabs.indices, id: \.self) { index in
            Webview(tab: $tabs[index]).zIndex(index == activeTabIndex ? Double(tabs.count) : 0)
          }
        }
      }
      
//      if browser.tabs.indices.contains(activeTabIndex) {
//        Webview(tab: $browser.tabs[activeTabIndex])
//      }
      
//      switch browser.activeTabIndex {
//        case 0:
//          Webview(tab: $browser.tabs[0])
//        case 1:
//          Webview(tab: $browser.tabs[1])
//        case 2:
//          Webview(tab: $browser.tabs[2])
//        default:
//          Spacer()
//      }
      
      
    }
    .ignoresSafeArea(.container, edges: .top)
    .multilineTextAlignment(.leading)
    .onAppear {
      let newTab = Tab(webURL: DEFAULT_URL)
      tabs.append(newTab)
      activeTabIndex = 0
    }
  }
}
