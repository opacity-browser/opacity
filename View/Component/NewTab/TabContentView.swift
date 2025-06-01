//
//  TabContentView.swift
//  Opacity
//
//  Created by Falsy on 5/31/25.
//

import SwiftUI
import SwiftData

struct TabContentView: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  let isActive: Bool
  let geometryHeight: CGFloat
  
  var body: some View {
    Group {
      if tab.isInit {
        NewTabView(browser: browser, tab: tab)
      } else {
        WebviewArea(service: service, browser: browser, tab: tab)
      }
    }
    .offset(y: isActive ? 0 : geometryHeight + 1)
    .frame(height: geometryHeight + 1)
    .onChange(of: tab.isClearWebview) { _, newValue in
      if newValue && tab.isInit {
        DispatchQueue.main.async {
          tab.isClearWebview = false
          if let completion = tab.complateCleanUpWebview {
            completion()
          }
        }
      }
    }
    .onDisappear {
      print("TabContentView disappeared for tab: \(tab.id)")
    }
  }
}
