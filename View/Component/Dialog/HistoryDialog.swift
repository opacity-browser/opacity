//
//  HistoryDialog.swift
//  Opacity
//
//  Created by Falsy on 2/17/24.
//

import SwiftUI

struct HistoryDialog: View {
  @ObservedObject var tab: Tab
  var isBack: Bool
  @Binding var closeDialog: Bool
  
  var body: some View {
    let historyList = isBack ? tab.historyBackList : tab.historyForwardList
    let reverseHistoryList = isBack ? historyList.reversed() : historyList
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(spacing: 0) {
            ForEach(reverseHistoryList, id: \.self) { item in
              HistoryDialogItem(tab: tab, item: item, closeDialog: $closeDialog)
            }
          }
        }
        .frame(maxWidth: 240, maxHeight: 300)
      }
      .padding(.vertical, 5)
    }
    .frame(width: 240, height: (CGFloat(reverseHistoryList.count) * 30 + 10) > 300 ? 300 : CGFloat(reverseHistoryList.count) * 30 + 10)
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
