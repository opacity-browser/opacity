//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

enum WebViewErrorType {
  case notFindHost
  case notConnectHost
  case notConnectInternet
  case timeOut
  case unkown
  case noError
}

class WebviewError {
  var isError: Bool = false
  var checkError: Bool = false
  var errorType: WebViewErrorType = .noError
  static var share = WebviewError()
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
    var errorPages: [WKBackForwardListItem: URL] = [:]
    var errorOriginURL: URL?
    
    init(_ parent: Webview) {
      self.parent = parent
    }
    
    func getCurrentItem(of webView: WKWebView) -> WKBackForwardListItem? {
      guard let currentItem = webView.backForwardList.currentItem else {
        return nil
      }
      return currentItem
    }
    
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//      print("didStartProvisionalNavigation")
//      if let currentItem = getCurrentItem(of: webView) {
//        print("============= did start currentItem: \(currentItem)")
//      }
//      WebviewError.share.isError = false
//      if WebviewError.share.checkError {
//        WebviewError.share.checkError = false
//        WebviewError.share.isError = true
//      }
//    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
      print("============= didComit currentItem: \(getCurrentItem(of: webView)!)")
      
      WebviewError.share.isError = false
      if WebviewError.share.checkError {
        WebviewError.share.checkError = false
        WebviewError.share.isError = true
        
        if let errorURL = errorOriginURL, let currentItem = getCurrentItem(of: webView) {
          print("set error url: \(errorURL)")
          errorPages[currentItem] = errorURL
          errorOriginURL = nil
        }
      } else {
        if let currentItem = getCurrentItem(of: webView), let originalURL = errorPages[currentItem] {
          print("update error url: \(originalURL)")
          webView.load(URLRequest(url: originalURL))
          errorPages.removeValue(forKey: currentItem)
        }
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
      
      if WebviewError.share.isError {
        switch WebviewError.share.errorType {
          case .notFindHost:
            let title = NSLocalizedString("Page not found", comment: "")
            let message = String(format: NSLocalizedString("The server IP address for \\'%@\\' could not be found.", comment: ""), self.parent.tab.printURL)
            let href = self.parent.tab.originURL
            let refreshBtn = NSLocalizedString("Refresh", comment: "")
            
            webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(href)', title: '\(title)', refreshBtn: '\(refreshBtn)', message: '\(message)'})")
            webView.evaluateJavaScript("setErrorPageString()")
          case .notConnectHost:
            let title = NSLocalizedString("Unable to connect to site", comment: "")
            let message = NSLocalizedString("Connection has been reset.", comment: "")
            let href = self.parent.tab.originURL
            let refreshBtn = NSLocalizedString("Refresh", comment: "")
            
            webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(href)', title: '\(title)', refreshBtn: '\(refreshBtn)', message: '\(message)'})")
            webView.evaluateJavaScript("setErrorPageString()")
          case .notConnectInternet:
            let title = NSLocalizedString("No internet connection", comment: "")
            let message = NSLocalizedString("There is no internet connection.", comment: "")
            let href = self.parent.tab.originURL
            let refreshBtn = NSLocalizedString("Refresh", comment: "")
            
            webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(href)', title: '\(title)', refreshBtn: '\(refreshBtn)', message: '\(message)'})")
            webView.evaluateJavaScript("setErrorPageString()")
          case .timeOut:
            let title = NSLocalizedString("This site can't be reached", comment: "")
            let message = String(format: NSLocalizedString("\\'%@\\' took too long to respond.", comment: ""), self.parent.tab.printURL)
            let href = self.parent.tab.originURL
            let refreshBtn = NSLocalizedString("Refresh", comment: "")
            
            webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(href)', title: '\(title)', refreshBtn: '\(refreshBtn)', message: '\(message)'})")
            webView.evaluateJavaScript("setErrorPageString()")
          case .unkown:
            let title = NSLocalizedString("Unknown error", comment: "")
            let message = NSLocalizedString("An unknown error occurred.", comment: "")
            let href = self.parent.tab.originURL
            let refreshBtn = NSLocalizedString("Refresh", comment: "")
            
            webView.evaluateJavaScript("ErrorController.setPageData({ href: '\(href)', title: '\(title)', refreshBtn: '\(refreshBtn)', message: '\(message)'})")
            webView.evaluateJavaScript("setErrorPageString()")
          case .noError:
            break
        }
      }
      
      webView.evaluateJavaScript("document.title") { (response, error) in
        if let title = response as? String {
          DispatchQueue.main.async {
            self.parent.tab.title = title
          }
        }
      }
      
      if WebviewError.share.isError {
        self.parent.tab.setDefaultFavicon()
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
          let newTab = Tab(url: requestURL)
          self.parent.tabs.append(newTab)
          self.parent.activeTabIndex = parent.tabs.count - 1
        }
      }
      return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      if (error as NSError).code == NSURLErrorCancelled {
          return // 오류 무시
      }
      
      if let urlError = error as? URLError {
        if let failingURL = urlError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
          // 실패 도메인 캐시
          errorOriginURL = failingURL
        }
      }
      
      // 오류
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
      
      // 웹 콘텐츠 로딩 관련 오류
      if nsError.domain == NSURLErrorDomain {
        WebviewError.share.checkError = true
        WebviewError.share.isError = true
        
        print(nsError.code)
        
        switch nsError.code {
          case NSURLErrorCannotFindHost:
            // 호스트를 찾을 수 없는 경우 처리
            print("not-find-host")
            WebviewError.share.errorType = .notFindHost
            if let schemeURL = URL(string:"friedegg://not-find-host?lang=\(NSLocalizedString("lang", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
          case NSURLErrorSecureConnectionFailed:
            // 호스트에 연결할 수 없는 경우 처리
            print("not-connect-host")
            WebviewError.share.errorType = .notConnectHost
            if let schemeURL = URL(string:"friedegg://not-connect-host?lang=\(NSLocalizedString("lang", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
          case NSURLErrorNotConnectedToInternet:
            // 네트워크 연결 끊김 처리
            print("not-connect-internet")
            WebviewError.share.errorType = .notConnectInternet
            if let schemeURL = URL(string:"friedegg://not-connect-internet?lang=\(NSLocalizedString("lang", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
          default:
            // 기타 오류 처리
            print("unknown")
            WebviewError.share.errorType = .unkown
            if let schemeURL = URL(string:"friedegg://unknown?lang=\(NSLocalizedString("lang", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
        }
      }
    }
  }
      
  func makeNSView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    config.defaultWebpagePreferences = prefs
    
    let schemeHandler = SchemeHandler()
    config.setURLSchemeHandler(schemeHandler, forURLScheme: "friedegg")
    
//    let scriptSource = "window.customProperty = { customMethod: function() { alert('This is a custom method!'); } };"
//    let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
//    config.userContentController.addUserScript(userScript)
    
    let preferences = WKPreferences()
    preferences.setValue(true, forKey: "developerExtrasEnabled") // 개발자 도구 활성화
    config.preferences = preferences
    
//    let contentController = WKUserContentController()
//    config.userContentController = contentController
    
    let newWebview = WKWebView(frame: .zero, configuration: config)
    
    newWebview.navigationDelegate = context.coordinator
    newWebview.uiDelegate = context.coordinator
    newWebview.allowsBackForwardNavigationGestures = true
    newWebview.isInspectable = true
    
    tab.webview = newWebview
    return newWebview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    print("############# 웹뷰 업데이트 호출: update")
    print("webview url: \(String(describing: webView.url))")
    print("tab origin url: \(String(describing: tab.originURL))")
    print("WebviewError.share.isError: \(WebviewError.share.isError)")
    
    if !tab.isUpdateBySearch && WebviewError.share.isError {
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
      WebviewError.share.isError = false
      print("update by searchURL - return")
      webView.load(URLRequest(url: tab.originURL))
      return
    }
    
    print("no update, set tab data by webview data - return")
    tab.updateURLByBrowser(url: webviewURL)
  }
}
