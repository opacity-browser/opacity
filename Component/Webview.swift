//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

struct Webview: NSViewRepresentable {
  @Binding var tab: Tab
  
  func makeCoordinator() -> Coordinator {
      Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
      let parent: Webview
      
      init(_ parent: Webview) {
          self.parent = parent
      }
      
      func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("############# 코디네이터 호출: didStartProvisionalNavigation")
//        print("webview url: \(String(describing: webView.url))")
//        print("webview site url: \(parent.tab.webURL)")
//        print("input url: \(parent.tab.inputURL )")
//          
//        var nowWebviewURL: String = ""
//        var nowWebviewStringURL: String = ""
//        if let stringURL = webView.url {
//          nowWebviewStringURL = String(describing: stringURL)
//          nowWebviewURL = String(describing: stringURL)
//          nowWebviewURL = StringURL.removeLastSlash(url: nowWebviewURL)
//        }
//        
//        if parent.tab.webURL != nowWebviewURL {
//          parent.tab.webURL = nowWebviewURL
//          parent.tab.viewURL = StringURL.shortURL(url: nowWebviewURL)
//          parent.tab.inputURL = StringURL.removeLastSlash(url: nowWebviewStringURL)
//        }
      }
      
      func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("############# 리다이렉트 호출: didReceiveServerRedirectForProvisionalNavigation")
//        print("webview redirect url: \(String(describing: webView.url))")
//        print("webview title2: \(String(describing: webView.title))")
//        var nowWebviewURL: String = ""
//        var nowWebviewStringURL: String = ""
//        if let stringURL = webView.url {
//          nowWebviewStringURL = String(describing: stringURL)
//          nowWebviewURL = String(describing: stringURL)
//          nowWebviewURL = StringURL.removeLastSlash(url: nowWebviewURL)
//          
//          parent.tab.webURL = nowWebviewURL
//          parent.tab.viewURL = StringURL.shortURL(url: nowWebviewURL)
//          parent.tab.inputURL = StringURL.removeLastSlash(url: nowWebviewStringURL)
//        }
      }
      
      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("############# didFinish")
        self.parent.tab.isBack = webView.canGoBack
        self.parent.tab.isForward = webView.canGoForward

        webView.evaluateJavaScript("document.title") { (response, error) in
          if let title = response as? String {
            self.parent.tab.title = title
          }
        }

        webView.evaluateJavaScript("document.querySelector(\"link[rel*='icon']\").getAttribute(\"href\")") { (response, error) in
          if let faviconURL = response as? String, !faviconURL.isEmpty {
            if faviconURL.contains("://") {
              self.parent.tab.favicon = faviconURL
            } else {
              if let pageURL = webView.url {
                if let host = pageURL.host {
                  let fullDomain = pageURL.scheme! + "://" + host
                  self.parent.tab.favicon = fullDomain + faviconURL
                }
              }
            }
          }
        }
      }
      
      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("############# 새창으로 웹뷰 호출")
//        if navigationAction.targetFrame == nil {
//          // 새 창 링크를 현재 웹뷰에서 로드
//          webView.load(navigationAction.request)
//        }
      return nil
    }
  }
      
  func makeNSView(context: Context) -> WKWebView {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    
    let newWebview = WKWebView(frame: .zero, configuration: config)
    newWebview.navigationDelegate = context.coordinator
    newWebview.uiDelegate = context.coordinator
    newWebview.allowsBackForwardNavigationGestures = true
    
    tab.webview = newWebview
    newWebview.load(URLRequest(url: URL(string: tab.originURL)!))
    return newWebview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    print("############# 웹뷰 업데이트 호출: update")
//    var nowWebviewURL: String = ""
//    var nowWebviewStringURL: String = ""
//    if let stringURL = webView.url {
//      nowWebviewStringURL = String(describing: stringURL)
//      nowWebviewURL = String(describing: stringURL)
//      nowWebviewURL = StringURL.shortURL(url: nowWebviewURL)
//    }
//      
//    let stateURL: String = StringURL.shortURL(url: tab.webURL)
//
//    if(stateURL == nowWebviewURL) {
//      if StringURL.shortURL(url: tab.viewURL) != stateURL {
//        tab.viewURL = stateURL
//      }
//      return
//    }
//    
//    if nowWebviewStringURL != "" {
//      if tab.goToPage {
//        webView.load(URLRequest(url: URL(string: tab.webURL)!))
//        DispatchQueue.main.async {
//          tab.goToPage = false
//        }
//      } else {
//        webView.load(URLRequest(url: URL(string: nowWebviewStringURL)!))
//      }
//    } else {
//      webView.load(URLRequest(url: URL(string: tab.webURL)!))
//    }
  }
}
