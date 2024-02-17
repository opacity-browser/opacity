//
//  HistoryDialog.swift
//  FriedEgg
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
        .frame(maxWidth: 250, maxHeight: 300)
      }
      .padding(.vertical, 5)
    }
    .frame(width: 250)
  }
}
