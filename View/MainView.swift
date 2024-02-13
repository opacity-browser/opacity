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
  @ObservedObject var browser: Browser
//  @Binding var tabs: [Tab]
//  @Binding var activeTabId: UUID?
//  @Binding var progress: Double
  
  @State var test: Bool = true
  
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
        if browser.tabs.count > 0 && test {
//          Rectangle() // 최상위 뷰를 제외한 나머지를 가리는 투명한 레이어
//            .foregroundColor(.red)
//            .allowsHitTesting(false)
//            .onHover { inside in
//              print(inside)
//              if inside {
//                NSCursor.arrow.set() // 마우스가 위에 있을 때 화살표 커서를 강제로 설정
//              }
//            }
//            .zIndex(Double(tabs.count + 1))
          ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
            if let activeId = browser.activeTabId {
              Webview(browser: browser, tabId: tab.id)
                .zIndex(tab.id == activeId ? Double(browser.tabs.count) : 0)
            }
//            tab.printWebview
//              .zIndex(tab.id == browser.activeTabId ? Double(browser.tabs.count) : 0)
//            if let activeId = activeTabId {
//              Webview(browser: browser, activeTabId: $activeTabId, tab: browser.tabs[index], progress: $progress)
//                .zIndex(tab.id == activeId ? Double(browser.tabs.count) : 0)
              //                .frame(maxWidth: tab.id == activeId ? .infinity : 0)
              //                .background(.blue)
              //                .opacity(0.5)
//            }
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
