//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
  @ObservedObject var browser: Browser

  var body: some View {
    VStack(spacing: 0) {
      // webview area
      ZStack {
        if browser.tabs.count > 0 {
          ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
//            if tab.id == browser.activeTabId {
//              Webview(browser: browser, tab: browser.tabs[index])
//            }
            if let activeId = browser.activeTabId {
              WebNSView(browser: browser, tab: browser.tabs[index])
                .zIndex(tab.id == activeId ? Double(browser.tabs.count) : 0)
            }
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
