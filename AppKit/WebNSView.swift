//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

struct WebNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    var parent: WebNSView
    var errorPages: [WKBackForwardListItem: URL] = [:]
    var errorOriginURL: URL?
    
    init(_ parent: WebNSView) {
      self.parent = parent
    }
    
    // Download Delegate Methods
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
      let savePanel = NSSavePanel()
      savePanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
      savePanel.nameFieldStringValue = suggestedFilename
      
      savePanel.begin { result in
        if result == .OK {
          completionHandler(savePanel.url)
        } else {
          completionHandler(nil)
        }
      }
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    }
    
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
      download.delegate = self
    }
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
      download.delegate = self
    }
    
    func webView(_ webView: WKWebView, download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
      print("Download failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, downloadDidFinish download: WKDownload) {
      print("Download finished successfully.")
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
      parent.tab.webviewIsError = false
      if parent.tab.webviewCheckError {
        parent.tab.webviewCheckError = false
        parent.tab.webviewIsError = true
        
        if let errorURL = errorOriginURL, let currentItem = getCurrentItem(of: webView) {
          errorPages[currentItem] = errorURL
          errorOriginURL = nil
        }
      } else {
        if let currentItem = getCurrentItem(of: webView), let originalURL = errorPages[currentItem] {
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
      
      if navigationAction.shouldPerformDownload {
        print("5")
        decisionHandler(.download)
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
      if let webviewURL = webView.url, webviewURL != parent.tab.originURL {
        webView.load(URLRequest(url: webviewURL))
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
      
      if parent.tab.webviewIsError {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let headTitle = parent.tab.printURL
        let href = parent.tab.originURL
        let refreshBtn = NSLocalizedString("Refresh", comment: "")
        var title = ""
        var message = ""
        
        switch parent.tab.webviewErrorType {
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
        
        if parent.tab.webviewErrorType != .noError {
          webView.evaluateJavaScript("""
          window.opacityPage.initPageData({
            lang: '\(lang)',
            href: '\(href)',
            headTitle: '\(headTitle)',
            title: '\(title)',
            refreshBtn: '\(refreshBtn)',
            message: '\(message)'})
         """)
        }
      }
      
      webView.evaluateJavaScript("""
      window.addEventListener('hashchange', function() {
        window.webkit.messageHandlers.opacityBrowser.postMessage({
          name: "hashChange",
          value: window.location.href
        });
      });
     """)
      
      var cacheTitle: String?
      group.enter()
      webView.evaluateJavaScript("document.title") { (response, error) in
        if let title = response as? String {
          
          DispatchQueue.main.async {
            cacheTitle = title
            self.parent.tab.title = title
            if let webviewURL = webView.url, let scheme = webviewURL.scheme, let host = webviewURL.host() {
              if scheme == "opacity" {
                if host == "settings" {
                  self.parent.tab.title = NSLocalizedString("Settings", comment: "")
                }
                if host == "new-tab" {
                  self.parent.tab.title = NSLocalizedString("New Tab", comment: "")
                }
              }
            }
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
            if let currentURL = webView.url {
              Task {
                let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
                await VisitManager.addVisitHistory(url: currentURL.absoluteString, title: title, faviconData: faviconData)
              }
            }
          }
          self.parent.tab.historySiteDataList.append(historySite)
        }
      }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, error)
      }
      task.resume()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      if let customAction = (webView as? OpacityWebView)?.contextualMenuAction, let requestURL = navigationAction.request.url {
        if customAction == .downloadImage {
          downloadImage(from: requestURL) { data, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
              let savePanel = NSSavePanel()
              savePanel.allowedContentTypes = [.png, .jpeg, .bmp, .gif]
              savePanel.canCreateDirectories = true
              savePanel.isExtensionHidden = false
              savePanel.title = "Save As"
              savePanel.nameFieldLabel = NSLocalizedString("Save As:", comment: "")
              if requestURL.lastPathComponent != "" {
                savePanel.nameFieldStringValue = requestURL.lastPathComponent
              }
              
              if savePanel.runModal() == .OK, let url = savePanel.url {
                do {
                  try data.write(to: url)
                  print("Image saved to \(url)")
                } catch {
                  print("Failed to save image: \(error)")
                }
              }
            }
          }
          
          return nil
        }
      }
      
      if navigationAction.targetFrame == nil {
        if let requestURL = navigationAction.request.url {
          self.parent.browser.newTab(requestURL)
        }
      }
      return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      parent.tab.pageProgress = webView.estimatedProgress
      if (error as NSError).code == NSURLErrorCancelled {
        return
      }
      if let urlError = error as? URLError {
        if let failingURL = urlError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
          errorOriginURL = failingURL
        }
      }
      handleWebViewError(webView: webView, error: error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      parent.tab.pageProgress = webView.estimatedProgress
      handleWebViewError(webView: webView, error: error)
    }
    
    // alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
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
      parent.tab.webviewCheckError = true
      parent.tab.webviewIsError = true
      
      switch nsError.code {
          //          case NSFileNoSuchFileError:
          //            // 파일을 찾을 수 없음
          //          case NSFileReadNoPermissionError:
          //            // 파일 읽기 권한 없음
          //          case NSFileReadCorruptFileError:
          //            // 손상된 파일
        case NSURLErrorCannotFindHost:
          parent.tab.webviewErrorType = .notFindHost
          if let schemeURL = URL(string:"opacity://not-find-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorCannotConnectToHost:
          parent.tab.webviewErrorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorSecureConnectionFailed:
          parent.tab.webviewErrorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorServerCertificateHasBadDate:
          parent.tab.webviewErrorType = .notConnectHost
          if let schemeURL = URL(string:"opacity://not-connect-host") {
            webView.load(URLRequest(url: schemeURL))
          }
        case NSURLErrorNotConnectedToInternet:
          parent.tab.webviewErrorType = .notConnectInternet
          if let schemeURL = URL(string:"opacity://not-connect-internet") {
            webView.load(URLRequest(url: schemeURL))
          }
        default:
          parent.tab.webviewErrorType = .unkown
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
    tab.webview.setValue(false, forKey: "drawsBackground")
    
    return tab.webview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    print("웹뷰 업데이트 시작")
    
    if !tab.isUpdateBySearch && tab.webviewIsError {
      print("업데이트가 아니며, 오류로 인한 업데이트 - 종료")
      return
    }
    
    guard let webviewURL = webView.url else {
      print("웹뷰의 url 없음 - 요청된 URL 로드 - 종료")
      webView.load(URLRequest(url: tab.originURL))
      return
    }
    
    if !tab.isUpdateBySearch && webviewURL == tab.originURL {
      print("업데이트가 아니며 탭의 url과 웹뷰의 url이 같음 - 종료")
      return
    }
    
    if tab.isUpdateBySearch {
      tab.isUpdateBySearch = false
      tab.webviewIsError = false
      print("새로운 검색으로 요청된 URL 로드 - 종료")
      webView.load(URLRequest(url: tab.originURL))
      return
    }

    print("웹페이지 내에서의 페이지 이동 요청으로, 웹뷰 URL로 다시 리로드 - 종료(재귀)")
    tab.updateURLByBrowser(url: webviewURL)
  }
}

