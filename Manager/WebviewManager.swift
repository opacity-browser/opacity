//
//  WebviewManager.swift
//  Opacity
//
//  Created by Falsy on 1/11/24.
//

import SwiftUI
import WebKit

final class WebviewManager {
  static let shared = WebviewManager()
  private var webviews: [UUID: WKWebView] = [:]

//  func webView(id: UUID) -> WKWebView {
//    if let webView = webViews[url] {
//      return webView
//    } else {
//      let newWebView = WKWebView()
//      newWebView.load(URLRequest(url: url))
//      webViews[url] = newWebView
//      return newWebView
//    }
//  }
  
  func getWebview(id: UUID) -> WKWebView? {
    print("get webview id: \(id)")
    if let webView = webviews[id] {
      return webView
    } else {
      return nil
    }
  }
  
  func setWebview(id: UUID, webview: WKWebView) {
    webviews[id] = webview
    print(webviews)
  }
}
