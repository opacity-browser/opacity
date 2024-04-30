//
//  HistoryBackBtn.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct HistoryBackBtn: View {
  @ObservedObject var tab: Tab
  
  @State private var isBackDialog: Bool = false
  
  var body: some View {
    HistoryKeyNSView(
      tab: tab,
      isBack: true,
      clickAction: {
        if tab.isBack {
          tab.webview.goBack()
        }
      },
      longPressAction: {
        if tab.isBack {
          self.isBackDialog = true
        }
      })
    .frame(width: 24, height: 24)
    .popover(isPresented: $isBackDialog, arrowEdge: .bottom) {
      HistoryDialog(tab: tab, isBack: true, closeDialog: $isBackDialog)
    }
  }
}