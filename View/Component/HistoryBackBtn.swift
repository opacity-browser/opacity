//
//  HistoryBackBtn.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct HistoryBackBtn: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @State private var isBackDialog: Bool = false
  
  var body: some View {
    HistoryKeyNSView(
      tab: tab,
      isBack: true,
      clickAction: { isCommand in
        if tab.canGoBackInHistory {
          if isCommand {
            // Command+클릭: 새 탭에서 이전 페이지 열기
            if tab.currentHistoryIndex > 0 {
              let previousHistorySite = tab.historySiteList[tab.currentHistoryIndex - 1]
              browser.newTab(previousHistorySite.url)
            }
          } else {
            // 일반 클릭: 통합 히스토리로 뒤로가기
            tab.goBackInHistory(browser: browser)
          }
        }
      },
      longPressAction: {
        if tab.canGoBackInHistory {
          self.tab.updateWebHistory = true
          self.isBackDialog = true
        }
      })
    .frame(width: 24, height: 24)
    .popover(isPresented: $isBackDialog, arrowEdge: .bottom) {
      HistoryDialog(tab: tab, browser: browser, isBack: true, closeDialog: $isBackDialog)
    }
  }
}
