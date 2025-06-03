//
//  WebviewArea.swift
//  Opacity
//
//  Created by Falsy on 4/11/24.
//

import SwiftUI

struct WebviewArea: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  var body: some View {
    VStack(spacing: 0) {
      if tab.showErrorPage, let errorType = tab.errorPageType {
        ErrorPageView(
          errorType: errorType,
          failingURL: tab.errorFailingURL
        ) {
          // 새로고침 액션
          if let url = URL(string: tab.errorFailingURL) {
            DispatchQueue.main.async {
              tab.showErrorPage = false
              tab.errorPageType = nil
              tab.errorFailingURL = ""
              tab.updateURLBySearch(url: url)
            }
          }
        }
      } else {
        MainWebView(service: service, browser: browser, tab: tab)
      }
    }
    .background(tab.originURL.scheme == "opacity" ? Color("SearchBarBG") : .white)
  }
}
