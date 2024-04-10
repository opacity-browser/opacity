//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
  @ObservedObject var browser: Browser
  
  var body: some View {
    HStack(spacing: 0) {
      GeometryReader { geometry in
        ZStack {
          if browser.tabs.count > 0 {
            ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
              if let activeId = browser.activeTabId {
                VStack(spacing: 0) {
                  WebviewArea(browser: browser, tab: browser.tabs[index])
                }
                .offset(y: tab.id == activeId ? 0 : geometry.size.height + 1)
                .frame(height: geometry.size.height + 1)
              }
            }
          }
        }
      }
      if browser.isSideBar {
        SideBarView(browser: browser)
      }
    }
  }
}
