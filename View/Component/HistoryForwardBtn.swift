//
//  HistoryForwardBtn.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct HistoryForwardBtn: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @State private var isForwardDialog: Bool = false
  
  var body: some View {
    HistoryKeyNSView(
      tab: tab,
      isBack: false,
      clickAction: { isCommand in
        if tab.canGoForwardInHistory {
          if isCommand {
            // Command+클릭: 새 탭에서 다음 페이지 열기
            if tab.currentHistoryIndex < tab.historySiteList.count - 1 {
              let nextHistorySite = tab.historySiteList[tab.currentHistoryIndex + 1]
              browser.newTab(nextHistorySite.url)
            }
          } else {
            // 일반 클릭: 통합 히스토리로 앞으로가기
            tab.goForwardInHistory(browser: browser)
          }
        }
      },
      longPressAction: {
        if tab.canGoForwardInHistory {
          self.tab.updateWebHistory = true
          self.isForwardDialog = true
        }
      })
    .frame(width: 24, height: 24)
    .popover(isPresented: $isForwardDialog, arrowEdge: .bottom) {
      HistoryDialog(tab: tab, browser: browser, isBack: false, closeDialog: $isForwardDialog)
    }
  }
}
