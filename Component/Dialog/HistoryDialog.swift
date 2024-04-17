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
    
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(spacing: 0) {
            ForEach(historyList, id: \.self) { item in
              HistoryDialogItem(tab: tab, item: item, closeDialog: $closeDialog)
            }
          }
          .padding(5)
        }
        .frame(maxWidth: 240, maxHeight: 300)
      }
      .padding(.vertical, 5)
    }
    .frame(width: 240)
    .background(GeometryReader { geometry in
      Color("WindowTitleBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
}
