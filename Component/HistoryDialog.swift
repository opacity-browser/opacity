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
  
  var body: some View {
    
    let historyList = isBack ? tab.historyBackList : tab.historyForwardList
    
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(spacing: 0) {
            Text("count: \(historyList.count)")
            ForEach(historyList, id: \.self) { item in
              VStack {
                Text(item.title ?? "Unknown")
                Text(item.url.absoluteString)
              }
            }
            Spacer()
          }
        }
        .frame(width: 250, height: 400)
      }
      .padding(.vertical, 5)
    }
    .frame(width: 250)
  }
}
