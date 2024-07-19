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
        if let webview = tab.webview, tab.isForward {
          if isCommand {
            if let previousURL = webview.backForwardList.forwardItem?.url {
              browser.newTab(previousURL)
            }
          } else {
            webview.goForward()
          }
        }
      },
      longPressAction: {
        if tab.isForward {
          self.tab.updateWebHistory = true
          self.isForwardDialog = true
        }
      })
    .frame(width: 24, height: 24)
    .popover(isPresented: $isForwardDialog, arrowEdge: .bottom) {
      HistoryDialog(tab: tab, isBack: false, closeDialog: $isForwardDialog)
    }
  }
}
