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
  case unkown
  case noError
}

class WebviewError {
  var isError: Bool = false
  var checkError: Bool = false
  var errorType: WebViewErrorType = .noError
  static var share = WebviewError()
}

struct WebNSView: NSViewRepresentable {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var parent: WebNSView
    var errorPages: [WKBackForwardListItem: URL] = [:]
    var errorOriginURL: URL?
    
    init(_ parent: WebNSView) {
      self.parent = parent
    }
    
    func getCurrentItem(of webView: WKWebView) -> WKBackForwardListItem? {
      guard let currentItem = webView.backForwardList.currentItem else {
        return nil
      }
      return currentItem
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      parent.tab.pageProgress = webView.estimatedProgress
    }
    
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
      let group = DispatchGroup()
      
      DispatchQueue.main.async {
        self.parent.tab.pageProgress = webView.estimatedProgress
        self.parent.tab.isBack = webView.canGoBack
        self.parent.tab.isForward = webView.canGoForward
        self.parent.tab.historyBackList = webView.backForwardList.backList
        self.parent.tab.historyForwardList = webView.backForwardList.forwardList
      }
      
      let historyList = webView.backForwardList.backList + webView.backForwardList.forwardList
      let historyUrlList = historyList.compactMap { $0.url }
      
      self.parent.tab.historySiteDataList = self.parent.tab.historySiteDataList.filter { item in
        historyUrlList.contains(item.url)
      }
      
      if WebviewError.share.isError {
        let headTitle = parent.tab.printURL
        let href = parent.tab.originURL
        let refreshBtn = NSLocalizedString("Refresh", comment: "")
        var title = ""
        var message = ""
        
        switch WebviewError.share.errorType {
          case .notFindHost:
            title = NSLocalizedString("Page not found", comment: "")
            message = String(format: NSLocalizedString("The server IP address for \\'%@\\' could not be found.", comment: ""), parent.tab.printURL)
            break
          case .notConnectHost:
            title = NSLocalizedString("Unable to connect to site", comment: "")
            message = NSLocalizedString("Connection has been reset.", comment: "")
            break
          case .notConnectInternet:
            title = NSLocalizedString("No internet connection", comment: "")
            message = NSLocalizedString("There is no internet connection.", comment: "")
            break
          case .unkown:
            title = NSLocalizedString("Unknown error", comment: "")
            message = NSLocalizedString("An unknown error occurred.", comment: "")
            break
          case .noError:
            break
        }
        
        if WebviewError.share.errorType != .noError {
          webView.evaluateJavaScript("""
          window.opacityPage.initPageData({ 
            href: '\(href)',
            headTitle: '\(headTitle)',
            title: '\(title)',
            refreshBtn: '\(refreshBtn)',
            message: '\(message)'})
         """)
        }
      }
    
      var cacheTitle: String?
      group.enter()
      webView.evaluateJavaScript("document.title") { (response, error) in
        if let title = response as? String {
          DispatchQueue.main.async {
            cacheTitle = title
            self.parent.tab.title = title
            group.leave()
          }
        } else {
          group.leave()
        }
      }
      
      var cacheFaviconURL: URL?
      group.enter()
      webView.evaluateJavaScript("document.querySelector(\"link[rel*='icon']\").getAttribute(\"href\")") { (response, error) in
        guard let href = response as? String, let currentURL = webView.url else {
          if let webviewURL = webView.url {
            if webviewURL.scheme != "opacity" {
              let faviconURL = webviewURL.scheme! + "://" + webviewURL.host! + "/favicon.ico"
              DispatchQueue.main.async {
                cacheFaviconURL = URL(string: faviconURL)!
                self.parent.tab.loadFavicon(url: URL(string: faviconURL)!)
                group.leave()
              }
            } else {
              group.leave()
            }
          } else {
            group.leave()
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

        DispatchQueue.main.async {
          cacheFaviconURL = faviconURL
          self.parent.tab.loadFavicon(url: faviconURL)
          group.leave()
        }
      }
      
      group.notify(queue: .main) {
        if let title = cacheTitle {
          let historySite = HistorySite(title: title, url: self.parent.tab.originURL)
          if let faviconURL = cacheFaviconURL {
            historySite.loadFavicon(url: faviconURL)
          }
          self.parent.tab.historySiteDataList.append(historySite)
        }
      }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      print("############# 새탭으로 웹뷰 호출")
      if navigationAction.targetFrame == nil {
        if let requestURL = navigationAction.request.url {
          self.parent.browser.newTab(requestURL)
        }
      }
      return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      if (error as NSError).code == NSURLErrorCancelled {
          return // 오류 무시
      }
      print("didfailProvisional")
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
      parent.tab.pageProgress = webView.estimatedProgress
      print("didFail")
      handleWebViewError(webView: webView, error: error)
    }
    
    // alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
      print("alert")
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .warning
      alert.beginSheetModal(for: webView.window!) { _ in
        completionHandler()
      }
    }
    
    // confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .warning
      alert.beginSheetModal(for: webView.window!) { response in
        completionHandler(response == .alertFirstButtonReturn)
      }
    }
    
    // prompt
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
      print("prompt")
      let alert = NSAlert()
      alert.messageText = prompt
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .informational
      
      let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
      textField.stringValue = defaultText ?? ""
      alert.accessoryView = textField
      
      alert.beginSheetModal(for: webView.window!) { response in
        if response == .alertFirstButtonReturn {
          completionHandler(textField.stringValue)
        } else {
          completionHandler(nil)
        }
      }
    }
    
    // file upload
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
      let openPanel = NSOpenPanel()
      openPanel.canChooseFiles = true
      openPanel.canChooseDirectories = false
      openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
      
      openPanel.beginSheetModal(for: webView.window!) { response in
        if response == .OK {
          completionHandler(openPanel.urls)
        } else {
          completionHandler(nil)
        }
      }
    }
    
    private func handleWebViewError(webView: WKWebView, error: Error) {
      let nsError = error as NSError
      print("in webview error func")
      WebviewError.share.checkError = true
      WebviewError.share.isError = true
      
      switch nsError.code {
          //          case NSFileNoSuchFileError:
          //            // 파일을 찾을 수 없음
          //            print("요청한 파일을 찾을 수 없습니다. 파일 경로를 확인해주세요.")
          //          case NSFileReadNoPermissionError:
          //            // 파일 읽기 권한 없음
          //            print("파일을 읽을 권한이 없습니다. 권한 설정을 확인해주세요.")
          //          case NSFileReadCorruptFileError:
          //            // 손상된 파일
          //            print("파일이 손상되었습니다. 파일을 확인하거나 다시 다운로드해주세요.")
        case NSURLErrorCannotFindHost:
          // 호스트를 찾을 수 없는 경우 처리
          print("NSURLErrorCannotFindHost")
          WebviewError.share.errorType = .notFindHost
          if let schemeURL = URL(string:"opacity://not-find-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorCannotConnectToHost:
          // 호스트에 연결할 수 없음
          print("NSURLErrorCannotConnectToHost")
          WebviewError.share.errorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorSecureConnectionFailed:
          // 보안 연결 실패
          print("NSURLErrorSecureConnectionFailed")
          WebviewError.share.errorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorServerCertificateHasBadDate:
          // 서버 인증서 유효하지 않음
          print("not-connect-host")
          WebviewError.share.errorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorNotConnectedToInternet:
          // 인터넷 연결이 없음
          print("not-connect-internet")
          WebviewError.share.errorType = .notConnectInternet
          if let schemeURL = URL(string:"opacity://not-connect-internet") {
            webView.load(URLRequest(url: schemeURL))
          }
        default:
          // 기타 오류 처리
          print("unknown")
          WebviewError.share.errorType = .unkown
          if let schemeURL = URL(string:"opacity://unknown") {
            webView.load(URLRequest(url: schemeURL))
          }
      }
    }
  }
      
  func makeNSView(context: Context) -> WKWebView {
    tab.webview.navigationDelegate = context.coordinator
    tab.webview.uiDelegate = context.coordinator
    tab.webview.allowsBackForwardNavigationGestures = true
    tab.webview.isInspectable = true
    
    return tab.webview
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
