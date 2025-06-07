//
//  HistoryDialogItem.swift
//  Opacity
//
//  Created by Falsy on 2/18/24.
//

import SwiftUI
import WebKit

struct UnifiedHistoryDialogItem: View {
  @ObservedObject var tab: Tab
  @ObservedObject var browser: Browser
  var historySite: HistorySite
  var targetIndex: Int
  @Binding var closeDialog: Bool
  
  @State private var isHistoryHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if let favicon = historySite.favicon {
          HStack(spacing: 0) {
            VStack(spacing: 0) {
              favicon
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 14, maxHeight: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .clipped()
                .opacity(historySite.faviconOpacity)
            }
            .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
          }
          .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
        } else {
          Image(systemName: "globe")
            .font(.system(size: 12))
            .foregroundColor(Color("Icon"))
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
        }
        
        Text(historySite.title.isEmpty ? historySite.url.absoluteString : historySite.title)
          .frame(maxWidth: 210, maxHeight: 20, alignment: .leading)
          .font(.system(size: 12))
          .padding(.leading, 5)
          .lineLimit(1)
          .truncationMode(.tail)
      }
      .frame(height: 20)
      .padding(5)
      .onHover { hovering in
        isHistoryHover = hovering
      }
      .background(Color("SearchBarBG").opacity(isHistoryHover ? 0.5 : 0))
      .clipShape(RoundedRectangle(cornerRadius: 5))
      .onTapGesture {
        // 특정 인덱스로 직접 이동 (navigateToHistoryIndex에서 인덱스 설정함)
        tab.navigateToHistoryIndex(targetIndex, browser: browser)
        closeDialog = false
      }
    }
    .padding(.horizontal, 5)
  }
}

struct HistoryDialogItem: View {
  @ObservedObject var tab: Tab
  var item: WKBackForwardListItem
  @Binding var closeDialog: Bool
  
  @State private var isHistoryHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if let siteData = tab.historySiteList.first(where: { $0.url == item.url }) {
          if let favicon = siteData.favicon {
            HStack(spacing: 0) {
              VStack(spacing: 0) {
                favicon
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(maxWidth: 14, maxHeight: 14)
                  .clipShape(RoundedRectangle(cornerRadius: 4))
                  .clipped()
                  .opacity(siteData.faviconOpacity)
              }
              .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
            }
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
          }
          Text(siteData.title == "" ? item.url.absoluteString : siteData.title)
            .frame(maxWidth: 230, maxHeight: 20, alignment: .leading)
            .font(.system(size: 12))
            .padding(.leading, 5)
            .lineLimit(1)
            .truncationMode(.tail)
        } else {
          Text(item.url.absoluteString)
            .frame(maxWidth: 230, maxHeight: 20, alignment: .leading)
            .font(.system(size: 12))
            .padding(.leading, 5)
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }
      .frame(height: 20)
      .padding(5)
      .onHover { hovering in
        isHistoryHover = hovering
      }
      .background(Color("SearchBarBG").opacity(isHistoryHover ? 0.5 : 0))
      .clipShape(RoundedRectangle(cornerRadius: 5))
      .onTapGesture {
        if let webview = tab.webview {
          webview.go(to: item)
        }
        closeDialog = false
      }
    }
    .padding(.horizontal, 5)
  }
}
