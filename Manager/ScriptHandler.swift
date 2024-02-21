//
//  ScriptHandler.swift
//  Opacity
//
//  Created by Falsy on 2/21/24.
//

import SwiftUI
import WebKit

class ScriptHandler: NSObject, WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? String, let webView = message.webView {
      guard let currentURL = webView.url, currentURL.scheme == "opacity" else {
        return
      }
      
      print("OK - \(messageBody)")
//
//        if let currentURL = webView.url, currentURL.scheme == "opacity" {
//          
//        } else {
//          
//        }
//          print("Received message from JavaScript: \(messageBody)")
//          // 여기에서 Swift 코드로 메시지를 처리합니다.
    }
  }
}
