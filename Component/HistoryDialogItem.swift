//
//  HistoryDialogItem.swift
//  Opacity
//
//  Created by Falsy on 2/18/24.
//

import SwiftUI
import WebKit

struct HistoryDialogItem: View {
  @ObservedObject var tab: Tab
  var item: WKBackForwardListItem
  @Binding var closeDialog: Bool
  
  @State private var isHistoryHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if let siteData = tab.historySiteDataList.first(where: { $0.url == item.url }) {
          if let favicon = siteData.favicon {
            HStack(spacing: 0) {
              VStack(spacing: 0) {
                favicon
                  .resizable() // 이미지 크기 조절 가능하게 함
                  .aspectRatio(contentMode: .fill)
                  .frame(maxWidth: 14, maxHeight: 14)
                  .clipShape(RoundedRectangle(cornerRadius: 4))
                  .clipped()
              }
              .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
            }
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
          }
          Text(siteData.title)
            .frame(maxWidth: 230, maxHeight: 22, alignment: .leading)
            .font(.system(size: 12))
            .padding(.leading, siteData.favicon != nil ? 5 : 10)
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }
      .frame(height: 22)
      .padding(5)
      .onHover { hovering in
        isHistoryHover = hovering
      }
      .background(Color("SearchBarBG").opacity(isHistoryHover ? 0.5 : 0))
      .clipShape(RoundedRectangle(cornerRadius: 5))
      .onTapGesture {
        tab.webview.go(to: item)
        closeDialog = false
      }
    }
    .padding(.horizontal, 5)
  }
}
