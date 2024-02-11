//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
//  @Environment(\.colorScheme) var colorScheme
//  @ObservedObject var service: Service
//  var windowNo: Int
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  @Binding var progress: Double
  
  var body: some View {
    VStack(spacing: 0) {
      // webview area
      ZStack {
//        ForEach(service.browsers.map { $0.key }, id: \.self) { key in
//          if let browser = service.browsers[key] {
//            ForEach(browser.tabs, id: \.id) { tab in
//              if let activeId = activeTabId, let tab = tabs.first(where: { $0.id == activeId }) {
//                Webview(
//                  tabs: $tabs,
//                  activeTabId: $activeTabId,
//                  tab: tab,
//                  progress: $progress
//                ).zIndex(tab.id == activeId && key == windowNo ? 10 : 0)
//              }
//            }
//          }
//        }
        if tabs.count > 0 {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
            if let activeId = activeTabId {
              Webview(tabs: $tabs, activeTabId: $activeTabId, tab: tabs[index], progress: $progress)
                .zIndex(tab.id == activeId ? Double(tabs.count) : 0)
            }
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
