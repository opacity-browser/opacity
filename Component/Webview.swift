//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit


class WebviewError {
  var isError: Bool = false
  var checkError: Bool = false
  static var share = WebviewError()
}

class MyScriptMessageHandler: NSObject, WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "myHandler" {
      // JavaScript에서 보낸 메시지 처리
      print("Received message: \(message.body)")
    }
  }
}

struct Webview: NSViewRepresentable {
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @ObservedObject var tab: Tab
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var parent: Webview
    
    init(_ parent: Webview) {
        self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      print("didStartProvisionalNavigation")
      WebviewError.share.isError = false
      if WebviewError.share.checkError {
        WebviewError.share.checkError = false
        WebviewError.share.isError = true
      }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      guard let url = navigationAction.request.url else {
        decisionHandler(.cancel)
        return
      }

      if url.scheme == "http" {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.scheme = "https"

        if let httpsUrl = components.url {
          webView.load(URLRequest(url: httpsUrl))
          decisionHandler(.cancel)
          return
        }
      }

      decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
      print("############# 리다이렉트 호출: didReceiveServerRedirectForProvisionalNavigation")
      print("webview redirect url: \(String(describing: webView.url))")
      print("tab origin url: \(String(describing: parent.tab.originURL))")

      if let webviewURL = webView.url {
        if String(describing: webviewURL) != String(describing: parent.tab.originURL) {
          webView.load(URLRequest(url: webviewURL))
        }
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      print("############# didFinish")
      
      DispatchQueue.main.async {
        self.parent.tab.isBack = webView.canGoBack
        self.parent.tab.isForward = webView.canGoForward
      }

      webView.evaluateJavaScript("document.title") { (response, error) in
        if let title = response as? String {
          DispatchQueue.main.async {
            self.parent.tab.title = title
          }
        }
      }
      
      if WebviewError.share.isError {
        webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(self.parent.tab.originURL)'})")
        webView.evaluateJavaScript("setErrorHostString('\(self.parent.tab.printURL)')")
        print("set Script")
        return
      }

      webView.evaluateJavaScript("document.querySelector(\"link[rel*='icon']\").getAttribute(\"href\")") { (response, error) in
        guard let href = response as? String, let currentURL = webView.url else {
          if let webviewURL = webView.url {
            let faviconURL = webviewURL.scheme! + "://" + webviewURL.host! + "/favicon.ico"
            self.parent.tab.loadFavicon(url: URL(string: faviconURL)!)
          } else {
            self.parent.tab.setDefaultFavicon()
          }
          return
        }
        
        let faviconURL: URL
        if href.hasPrefix("http") {
          faviconURL = URL(string: href)!
        } else if href.hasPrefix("//") {
          faviconURL = URL(string: "https:\(href)")!
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
      if navigationAction.targetFrame == nil {
        if let requestURL = navigationAction.request.url {
          print("new tab url: \(requestURL)")
          let newTab = Tab(url: requestURL)
          self.parent.tabs.append(newTab)
          self.parent.activeTabIndex = parent.tabs.count - 1
        }
      }
      return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      if (error as NSError).code == NSURLErrorCancelled {
          return // 오류를 무시하거나 특별한 처리를 합니다.
      }
      // 오류 화면 표시 로직
      print("http 포함 오류")
      print(error)
      handleWebViewError(webView: webView, error: error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      print("didFail")
      handleWebViewError(webView: webView, error: error)
    }
    
    private func handleWebViewError(webView: WKWebView, error: Error) {
      let nsError = error as NSError
      
      print("in webive error func")
      
      // HTTP 요청 오류
      if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
          // 'http' 요청 관련 오류 처리
      }

      // 웹 콘텐츠 로딩 관련 오류
      if nsError.domain == NSURLErrorDomain {
        switch nsError.code {
          case NSURLErrorCannotFindHost:
            // 호스트를 찾을 수 없는 경우 처리
            print("not-find-host")
            if let schemeURL = URL(string: "friedegg://not-find-host") {
              webView.load(URLRequest(url: schemeURL))
              WebviewError.share.checkError = true
              WebviewError.share.isError = true
            }
          case NSURLErrorCannotConnectToHost:
            // 호스트에 연결할 수 없는 경우 처리
            print("not-connect-host")
          case NSURLErrorNetworkConnectionLost:
            // 네트워크 연결 끊김 처리
            print("lost-network-connect")
          default:
            // 기타 오류 처리
            print("unknown-error")
        }
      }
    }
  }
      
  func makeNSView(context: Context) -> WKWebView {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    let config = WKWebViewConfiguration()
    let schemeHandler = SchemeHandler()
    
    config.defaultWebpagePreferences = prefs
    config.setURLSchemeHandler(schemeHandler, forURLScheme: "friedegg")
    
//    let scriptSource = "window.customProperty = { customMethod: function() { alert('This is a custom method!'); } };"
//    let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
//    config.userContentController.addUserScript(userScript)
    
//    let preferences = WKPreferences()
//    preferences.setValue(true, forKey: "developerExtrasEnabled") // 개발자 도구 활성화
//    config.preferences = preferences
    
    let contentController = WKUserContentController()
    let handler = MyScriptMessageHandler()
    contentController.add(handler, name: "myHandler")
    config.userContentController = contentController
    
    let newWebview = WKWebView(frame: .zero, configuration: config)
    newWebview.navigationDelegate = context.coordinator
    newWebview.uiDelegate = context.coordinator
    newWebview.allowsBackForwardNavigationGestures = true
    
    tab.webview = newWebview
    newWebview.isInspectable = true
    return newWebview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    print("############# 웹뷰 업데이트 호출: update")
    print("webview url: \(String(describing: webView.url))")
    print("tab origin url: \(String(describing: tab.originURL))")
    print("WebviewError.share.isError: \(WebviewError.share.isError)")
    
    if WebviewError.share.isError {
      print("isError: true - return")
      return
    }
    
    guard let webviewURL = webView.url else {
      print("webview URL nil - return")
      webView.load(URLRequest(url: tab.originURL))
      return
    }
    
    if String(describing: webviewURL) == String(describing: tab.originURL) {
      print("webviewURL = tabURL - return")
      return
    }
    
    if tab.isUpdateBySearch {
      tab.isUpdateBySearch = false
      print("update by searchURL - return")
      webView.load(URLRequest(url: tab.originURL))
      return
    }
    
    print("no update, set tab data by webview data - return")
    tab.updateURLByBrowser(url: webviewURL)
  }
}
