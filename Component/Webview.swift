//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

struct Webview: NSViewRepresentable {
//  @Binding var tab: Tab
  @ObservedObject var tab: Tab
  
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
        
      }
      
      func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("############# 리다이렉트 호출: didReceiveServerRedirectForProvisionalNavigation")
        print("webview redirect url: \(String(describing: webView.url))")
        print("tab origin url: \(String(describing: parent.tab.originURL))")

        if let webviewURL = webView.url {
          let webviewStringURL = StringURL.removeLastSlash(url: String(describing: webviewURL))
          if webviewStringURL != StringURL.removeLastSlash(url: parent.tab.originURL) {
            parent.tab.originURL = webviewStringURL
            parent.tab.inputURL = StringURL.removeLastSlash(url: webviewStringURL)
            parent.tab.printURL = StringURL.shortURL(url: webviewStringURL)
          }
        }
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
          guard let href = response as? String, let currentURL = webView.url else {
            self.parent.tab.setDefaultFavicon()
            return
          }
          
          let faviconURL: URL
          if href.hasPrefix("http") {
            faviconURL = URL(string: href)!
          } else if href.hasPrefix("/") {
            var components = URLComponents(url: currentURL, resolvingAgainstBaseURL: true)!
            
            let splitHref = href.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: true)
            let pathPart = String(splitHref[0])
            let queryPart = splitHref.count > 1 ? String(splitHref[1]) : nil

            components.path = pathPart
            components.query = queryPart

            faviconURL = components.url!
          } else {
            faviconURL = URL(string: href, relativeTo: currentURL)!
          }
          
          self.parent.tab.loadFavicon(url: faviconURL)
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
//    newWebview.load(URLRequest(url: URL(string: tab.originURL)!))
    return newWebview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    print("############# 웹뷰 업데이트 호출: update")
    print("webview url: \(String(describing: webView.url))")
    print("tab origin url: \(String(describing: tab.originURL))")
    
    if let webviewURL = webView.url {
      let webviewStringURL = StringURL.removeLastSlash(url: String(describing: webviewURL))
      if webviewStringURL != StringURL.removeLastSlash(url: tab.originURL) {
        webView.load(URLRequest(url: URL(string: tab.originURL)!))
      }
    } else {
      webView.load(URLRequest(url: URL(string: tab.originURL)!))
    }
  }
}
