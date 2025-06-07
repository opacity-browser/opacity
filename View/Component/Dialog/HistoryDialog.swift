//
//  HistoryDialog.swift
//  Opacity
//
//  Created by Falsy on 2/17/24.
//

import SwiftUI

struct HistoryDialog: View {
  @ObservedObject var tab: Tab
  @ObservedObject var browser: Browser
  var isBack: Bool
  @Binding var closeDialog: Bool
  
  var historyItems: [HistorySite] {
    if isBack {
      // 현재 인덱스 이전의 아이템들 (역순)
      if tab.currentHistoryIndex > 0 {
        return Array(tab.historySiteList[0..<tab.currentHistoryIndex].reversed())
      }
      return []
    } else {
      // 현재 인덱스 이후의 아이템들
      if tab.currentHistoryIndex < tab.historySiteList.count - 1 {
        return Array(tab.historySiteList[(tab.currentHistoryIndex + 1)...])
      }
      return []
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(spacing: 0) {
            ForEach(Array(historyItems.enumerated()), id: \.offset) { index, historySite in
              UnifiedHistoryDialogItem(
                tab: tab,
                browser: browser,
                historySite: historySite,
                targetIndex: isBack ? (tab.currentHistoryIndex - index - 1) : (tab.currentHistoryIndex + index + 1),
                closeDialog: $closeDialog
              )
            }
          }
        }
        .frame(maxWidth: 240, maxHeight: 300)
      }
      .padding(.vertical, 5)
    }
    .frame(width: 240, height: (CGFloat(historyItems.count) * 30 + 10) > 300 ? 300 : CGFloat(historyItems.count) * 30 + 10)
    .background(GeometryReader { geometry in
      Color("DialogBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
}
