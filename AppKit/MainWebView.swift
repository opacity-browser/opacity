//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
@preconcurrency import WebKit
import Security
import CoreLocation
import ContentBlockRuleList
import ASN1Decoder

struct MainWebView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @State private var isSinglePageUpdate: Bool = false
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, URLSessionDelegate, CLLocationManagerDelegate {
    var parent: MainWebView
    var locationManager: CLLocationManager?
    var cacheErrorURL: URL?
    var reloadAttemptCount = 0
    var isCleanUpAction: Bool = false
    private var urlObservation: NSKeyValueObservation?
    
    init(_ parent: MainWebView) {
      self.parent = parent
      super.init()
      if let webview = self.parent.tab.webview {
        webview.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        webview.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
        urlObservation = webview.observe(\.url, options: .new) { [weak self] webView, change in
          if let newURL = change.newValue {
            self?.handleURLChange(newURL)
          }
        }
      }
    }
    
    deinit {
      if let webview = self.parent.tab.webview {
        webview.removeObserver(self, forKeyPath: "canGoBack")
        webview.removeObserver(self, forKeyPath: "canGoForward")
      }
      urlObservation?.invalidate()
    }
    
    private func normalizeURL(_ url: String) -> String {
      if url.hasSuffix("/") {
        return String(url.dropLast())
      }
      return url
    }
    
    private func handleURLChange(_ url: URL?) {
      if let url = url, normalizeURL(url.absoluteString) != normalizeURL(self.parent.tab.originURL.absoluteString) {
        self.parent.isSinglePageUpdate = true
      }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if let webview = self.parent.tab.webview {
        DispatchQueue.main.async {
          self.parent.tab.isBack = webview.canGoBack
          self.parent.tab.isForward = webview.canGoForward
        }
      }
    }
    
    // Find Text
    func searchWebView(_ webView: WKWebView, findText: String, isPrev: Bool) {
      let script = "window.find('\(findText)', false, \(isPrev), true);"
      webView.evaluateJavaScript(script, completionHandler: nil)
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
      print("didStartProvisionalNavigation")
      if isCleanUpAction == false {
        DispatchQueue.main.async {
          self.parent.tab.pageProgress = webView.estimatedProgress
        }
      }
    }
    
    private func getWebViewDocumentTitle(webView: WKWebView, group: DispatchGroup? = nil) {
      group?.enter()
      webView.evaluateJavaScript("document.title") { (response, error) in
        DispatchQueue.main.async {
          defer { group?.leave() }
          
          guard let title = response as? String else { return }
          self.parent.tab.title = title
          
          if let webviewURL = webView.url,
             let scheme = webviewURL.scheme,
             let host = webviewURL.host {
            switch (scheme, host) {
              case ("opacity", "settings"):
                self.parent.tab.title = NSLocalizedString("Settings", comment: "")
              case ("opacity", "new-tab"):
                self.parent.tab.title = NSLocalizedString("New Tab", comment: "")
              default:
                break
            }
          }
        }
      }
    }
    
    private func handleDefaultFavicon(for url: URL?) {
      guard let webviewURL = url, let scheme = webviewURL.scheme, let host = webviewURL.host else { return }
      
      if scheme == "opacity" {
        DispatchQueue.main.async {
          self.parent.tab.faviconURL = nil
          self.parent.tab.loadFavicon(url: nil)
        }
      } else {
        let faviconURL = URL(string: "\(scheme)://\(host)/favicon.ico")!
        DispatchQueue.main.async {
          self.parent.tab.faviconURL = faviconURL
          self.parent.tab.loadFavicon(url: faviconURL)
        }
      }
    }
    
    private func getWebViewDocumentFavicon(webView: WKWebView, group: DispatchGroup? = nil) {
      group?.enter()
      
      webView.evaluateJavaScript("""
        (function() {
          var link = document.querySelector("link[rel*='icon']");
          var baseURI = document.baseURI;
          var href = link ? link.getAttribute("href") : "";
          return { baseURI: baseURI, href: href };
        })()
     """) { (response, error) in
        guard let result = response as? [String: String],
              let baseURI = result["baseURI"],
              let href = result["href"],
              let cleanedHref = href.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let base = URL(string: baseURI),
              !cleanedHref.isEmpty else {
          self.handleDefaultFavicon(for: webView.url)
          group?.leave()
          return
        }
        
        let faviconURL: URL
        if cleanedHref.hasPrefix("http") {
          faviconURL = URL(string: cleanedHref)!
        } else if cleanedHref.hasPrefix("//") {
          faviconURL = URL(string: "https:\(cleanedHref)")!
        } else {
          faviconURL = URL(string: cleanedHref, relativeTo: base)!
        }
        
        DispatchQueue.main.async {
          self.parent.tab.faviconURL = faviconURL
          self.parent.tab.loadFavicon(url: faviconURL)
        }
        
        group?.leave()
      }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
      print("didCommit")
      if let webviewURL = webView.url {
        if webviewURL != self.parent.tab.originURL {
          if let errorContnetURL = self.cacheErrorURL, self.parent.tab.webviewIsError {
            self.checkedSSLCertificate(url: errorContnetURL)
            self.parent.tab.redirectURLByBrowser(url: errorContnetURL)
          } else {
            self.checkedSSLCertificate(url: webviewURL)
            self.parent.tab.redirectURLByBrowser(url: webviewURL)
          }
        } else {
          self.checkedSSLCertificate(url: webviewURL)
        }
      }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//      print("decidePolicyFor")
//      print("webView.url: \(webView.url)")
//      print("request.url: \(navigationAction.request.url)")
//      print("----")
      
      if let url = navigationAction.request.url, let errorURL = self.cacheErrorURL, url.scheme == "opacity", url.host == "errors", self.reloadAttemptCount == 0 {
        self.cacheErrorURL = nil
        self.reloadAttemptCount = 1
        print("error reload: \(errorURL)")
        webView.load(URLRequest(url: errorURL))
        decisionHandler(.cancel)
        return
      }
      
      guard let requestURL = navigationAction.request.url else {
        decisionHandler(.cancel)
        return
      }
      
      if navigationAction.modifierFlags.contains(.command) {
        self.parent.browser.newTab(requestURL)
        decisionHandler(.cancel)
        return
      }
      
      if navigationAction.shouldPerformDownload {
        decisionHandler(.download)
        return
      }
      
      decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
      print("didReceiveServerRedirectForProvisionalNavigation")
      if let webviewURL = webView.url, webviewURL != parent.tab.originURL {
        DispatchQueue.main.async {
          self.checkedSSLCertificate(url: webviewURL)
          self.parent.tab.redirectURLByBrowser(url: webviewURL)
        }
      }
    }
    
    @MainActor func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      print("didFinish")
      if let complateCleanUpWebview = self.parent.tab.complateCleanUpWebview, isCleanUpAction {
        DispatchQueue.main.async {
          webView.stopLoading()
          webView.removeObserver(self, forKeyPath: "canGoBack")
          webView.removeObserver(self, forKeyPath: "canGoForward")
          webView.navigationDelegate = nil
          webView.uiDelegate = nil
          webView.configuration.userContentController.removeAllScriptMessageHandlers()
          webView.removeFromSuperview()
          self.parent.tab.webview = nil
          URLCache.shared.removeAllCachedResponses()
          complateCleanUpWebview()
        }
        return
      }
      
      if let webviewURL = webView.url, let host = webviewURL.host, let scriptURL = Bundle.main.url(forResource: "removeAdblockThing", withExtension: "js"), 
          self.parent.service.isTrackerBlocking == true, host.contains("youtube.com") == true {
        do {
          let scriptContent = try String(contentsOf: scriptURL)
          webView.evaluateJavaScript(scriptContent, completionHandler: nil)
        } catch {
          print("Failed to load JavaScript file: \(error.localizedDescription)")
        }
      }
      
      DispatchQueue.main.async {
        self.parent.tab.pageProgress = 1.0
      }
      
      let historyList = webView.backForwardList.backList + webView.backForwardList.forwardList
      let historyUrlList = historyList.compactMap { $0.url }
      
      self.parent.tab.historySiteDataList = self.parent.tab.historySiteDataList.filter { item in
        historyUrlList.contains(item.url)
      }
      
      if parent.tab.webviewIsError { // error
        print("error page init script")
        parent.isSinglePageUpdate = false
      } else {// not error
        // Fetch Cookie
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
          var cacheCookies: [HTTPCookie] = []
          let currentURL = webView.url
          for cookie in cookies {
            if let url = currentURL, let _ = cookie.domain.range(of: url.host ?? "") {
              cacheCookies.append(cookie)
            }
          }
          DispatchQueue.main.async {
            self.parent.tab.cookies = cacheCookies
          }
        }
        
        // Fetch localStorage
        webView.evaluateJavaScript("JSON.stringify(window.localStorage)") { (result, error) in
          if let localStorage = result as? String {
            DispatchQueue.main.async {
              self.parent.tab.localStorage = localStorage
            }
          }
        }
        
        // Fetch sessionStorage
        webView.evaluateJavaScript("JSON.stringify(window.sessionStorage)") { (result, error) in
          if let sessionStorage = result as? String {
            DispatchQueue.main.async {
              self.parent.tab.sessionStorage = sessionStorage
            }
          }
        }
      }
      
      // Initial Geo Location
      initGeoPositions()
      
      webView.evaluateJavaScript("""
      window.addEventListener('hashchange', function() {
        window.webkit.messageHandlers.opacityBrowser.postMessage({
          name: "hashChange",
          value: window.location.href
        });
      });
     """)
      
      let group = DispatchGroup()
      
      // Webview Document Title
      getWebViewDocumentTitle(webView: webView, group: group)
      
      // Webview Document Favicon
      getWebViewDocumentFavicon(webView: webView, group: group)
    
    
      group.notify(queue: .main) {
        if let currentURL = webView.url {
          let historySite = HistorySite(title: self.parent.tab.title, url: self.parent.tab.originURL)
          if let faviconURL = self.parent.tab.faviconURL {
            historySite.loadFavicon(url: faviconURL)
            Task {
              let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
              VisitManager.addVisitHistory(url: currentURL.absoluteString, title: self.parent.tab.title, faviconData: faviconData)
              print("add visit OK")
            }
          }
          self.parent.tab.historySiteDataList.append(historySite)
        }
      }
      
      // 오류 페이지 리로드 무한 루프 방지
      self.reloadAttemptCount = 0
    }
    
    private func downloadImage(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, error)
      }
      task.resume()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      print("createWebViewWith")
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
      print("didFailProvisionalNavigation")
      parent.tab.pageProgress = 1.0
      if (error as NSError).code == NSURLErrorCancelled {
        return
      }
      
      handleWebViewError(webView: webView, error: error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      print("didFail")
      parent.tab.pageProgress = 1.0
      if (error as NSError).code == NSURLErrorCancelled {
        // 캐시된 페이지로 히스토리 이동 시 title 갱신을 위한 호출
        getWebViewDocumentTitle(webView: webView)
        getWebViewDocumentFavicon(webView: webView)
        return
      }
      
      handleWebViewError(webView: webView, error: error)
    }
    
    private func handleWebViewError(webView: WKWebView, error: Error) {
      let nsError = error as NSError
      print("handleWebViewError")
      print("Load failed with error: \(error.localizedDescription)")

      parent.tab.webviewIsError = true
      if let failingURL = nsError.userInfo["NSErrorFailingURLKey"] as? URL {
        self.cacheErrorURL = failingURL
        self.reloadAttemptCount = 1
        
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        parent.tab.inputURL = failingURL.absoluteString
        parent.tab.printURL = failingURL.absoluteString
        
        switch nsError.code {
            //          case NSFileNoSuchFileError:
            //            // 파일을 찾을 수 없음
            //          case NSFileReadNoPermissionError:
            //            // 파일 읽기 권한 없음
            //          case NSFileReadCorruptFileError:
            //            // 손상된 파일
          case 104:
            if let schemeURL = URL(string:"opacity://errors?type=blockedContent&lang=\(lang)&title=\(NSLocalizedString("Blocked content", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case WebKitErrorFrameLoadInterruptedByPolicyChange:
            print("Frame load interrupted by policy change: \(error.localizedDescription)")
            break
          case NSURLErrorCannotFindHost:
            if let schemeURL = URL(string:"opacity://errors?type=notFindHost&lang=\(lang)&title=\(NSLocalizedString("Page not found", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorCannotConnectToHost:
            if let schemeURL = URL(string:"opacity://errors?type=notConnectHost&lang=\(lang)&title=\(NSLocalizedString("Unable to connect to site", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorSecureConnectionFailed:
            if let schemeURL = URL(string:"opacity://errors?type=occurredSSLError&lang=\(lang)&title=\(NSLocalizedString("SSL/TLS certificate error", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorServerCertificateHasBadDate:
            if let schemeURL = URL(string:"opacity://errors?type=occurredSSLError&lang=\(lang)&title=\(NSLocalizedString("SSL/TLS certificate error", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorNotConnectedToInternet:
            if let schemeURL = URL(string:"opacity://errors?type=notConnectInternet&lang=\(lang)&title=\(NSLocalizedString("No internet connection", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          default:
            if let schemeURL = URL(string:"opacity://errors?type=unknown&lang=\(lang)&title=\(NSLocalizedString("Unknown error", comment: ""))") {
              webView.load(URLRequest(url: schemeURL))
            }
        }
      }
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
    
    private func matchesDomain(pattern: String, host: String) -> Bool {
      if pattern == host {
        return true
      }
      if pattern.hasPrefix("*.") {
        let basePattern = pattern.dropFirst(2)
        let hostParts = host.split(separator: ".")
        let patternParts = basePattern.split(separator: ".")
        if hostParts.count == patternParts.count + 1 {
          return Array(hostParts.suffix(patternParts.count)) == patternParts
        }
      }
      return false
    }
    
    private func matchesHostCertificate(certificate: SecCertificate, host: String) throws -> String? {
      let data = SecCertificateCopyData(certificate) as Data
      let x509 = try X509Certificate(data: data)
      if let cn = x509.subjectDistinguishedName {
        for pattern in x509.subjectAlternativeNames {
          if self.matchesDomain(pattern: pattern, host: host) {
            return cn
          }
        }
      }
      return nil
    }
    
    private var URLSessionHost: String = ""
    private var cacheisValidCertificate: Bool = false
    private var cacheCertificateSummary: String = ""
    
    func checkedSSLCertificate(url: URL) {
      DispatchQueue.main.async {
        self.parent.tab.certificateSummary = ""
        self.parent.tab.isValidCertificate = nil
      }
      
      self.cacheisValidCertificate = false
      self.cacheCertificateSummary = ""
      
      if url.scheme == "opacity" {
        return
      }
      
      if let host = url.host {
        self.URLSessionHost = host
      }
            
      let config = URLSessionConfiguration.default
      config.requestCachePolicy = .reloadIgnoringLocalCacheData
      config.urlCache = nil
      let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
      let request = URLRequest(url: url)
      let task = session.dataTask(with: request) { data, response, error in
        if error != nil {
          print("Error: \(error!.localizedDescription)")
        }
        DispatchQueue.main.async {
          self.parent.tab.certificateSummary = self.cacheCertificateSummary
          self.parent.tab.isValidCertificate = self.cacheisValidCertificate
        }
        session.finishTasksAndInvalidate()
      }
      task.resume()
    }
    
    func urlSession(
      _ session: URLSession,
      didReceive challenge: URLAuthenticationChallenge,
      completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
      if let serverTrust = challenge.protectionSpace.serverTrust {
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
        if isValid, let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
          for certificate in certificateChain {
            if let _ = try? matchesHostCertificate(certificate: certificate, host: self.URLSessionHost) {
              self.cacheisValidCertificate = true
              self.cacheCertificateSummary = SecCertificateCopySubjectSummary(certificate) as String? ?? "Unknown"
            }
          }
          completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
          completionHandler(.cancelAuthenticationChallenge, nil)
        }
      }
    }
    
    func setUserAgent(for webView: WKWebView) {
      webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
        if let userAgent = result as? String {
          var addAgentText = ""
          
          if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            addAgentText = " Opacity/" + version
          }
          
          if let range = userAgent.range(of: "AppleWebKit/") {
            let versionStartIndex = userAgent.index(range.upperBound, offsetBy: 0)
            let versionEndIndex = userAgent[versionStartIndex...].firstIndex(where: { !$0.isNumber && $0 != "." }) ?? userAgent.endIndex
            let safariVersion = String(userAgent[versionStartIndex..<versionEndIndex])
            addAgentText = addAgentText + " Safari/" + safariVersion
          }
          
          webView.customUserAgent = userAgent + addAgentText
        }
      }
    }
    
    // Geo Locaiton
    private func deniedGeolocation() {
      print("deniedGeolocation")
      guard let webview = self.parent.tab.webview else { return }
      let script = """
        navigator.geolocation.getCurrentPosition = function(success, error, options) {
          window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "requestWhenInUseAuthorization" });
          error({
            code: 1,
            message: 'User Denied Geolocation'
          });
        }
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    private func deniedGeolocationByHost() {
      print("deniedGeolocationByHost")
      guard let locationManager = locationManager, let webview = self.parent.tab.webview else { return }
      
      switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
          let script = """
            navigator.geolocation.getCurrentPosition = function(success, error, options) {
              window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "true" });
              error({
                code: 1,
                message: 'User Denied Geolocation'
              });
            }
          """
          webview.evaluateJavaScript(script, completionHandler: nil)
          break
        case .denied, .restricted, .notDetermined:
          deniedGeolocation()
          break
        @unknown default: break
      }
    }
    
    @MainActor private func initGeoPositions() {
      guard let webview = self.parent.tab.webview else { return }
      locationManager = CLLocationManager()
      locationManager!.desiredAccuracy = kCLLocationAccuracyBest
      locationManager!.distanceFilter = kCLDistanceFilterNone
      locationManager!.delegate = self

      switch locationManager!.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
          if let url = webview.url {
            if let locationPermition = PermissionManager.getLocationPermissionByURL(url: url) {
              if locationPermition.isDenied == false {
                locationManager!.startUpdatingLocation()
              }
            }
          }
          break
        case .denied, .restricted, .notDetermined:
          deniedGeolocation()
          break
        @unknown default: break
      }
    }
    
    func requestGeoLocationPermission() {
      guard let locationManager = locationManager else { return }
      locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      print("didChangeAuthorization")
      DispatchQueue.main.async {
        self.parent.tab.isLocationDialogIconByHost = false
      }
      guard let locationManager = locationManager, let webview = self.parent.tab.webview, let url = webview.url else { return }
      
      switch status {
        case .authorizedWhenInUse, .authorizedAlways:
          DispatchQueue.main.async {
            self.parent.tab.isLocationDialogIcon = false
          }
          if let locationPermition = PermissionManager.getLocationPermissionByURL(url: url) {
            if locationPermition.isDenied == false {
              locationManager.startUpdatingLocation()
              break
            }
          }
          deniedGeolocationByHost()
          break
        case .denied, .restricted:
          print("denied")
          deniedGeolocation()
          break
        default:
          break
      }
    }
    
    @MainActor func requestLocation() {
      guard let locationManager = locationManager else { return }
      print("requestLocation")
      locationManager.stopUpdatingLocation()
      locationManager.startUpdatingLocation()
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("didUpdateLocations")
      guard let location = locations.first, let webview = self.parent.tab.webview, let url = webview.url, let locationManager = locationManager else { return }
      if let locationPermition = PermissionManager.getLocationPermissionByURL(url: url) {
        if locationPermition.isDenied == false {
          print("allow geo location")
          let script = """
            navigator.geolocation.getCurrentPosition = function(success, error, options) {
              window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "false" });
              success({
                coords: {
                  latitude: \(location.coordinate.latitude),
                  longitude: \(location.coordinate.longitude)
                }
              });
            };
            navigator.geolocation.updatePosition(\(location.coordinate.latitude), \(location.coordinate.longitude));
          """

          webview.evaluateJavaScript(script, completionHandler: nil)
          locationManager.stopUpdatingLocation()
          return
        }
      }
      deniedGeolocationByHost()
    }
  
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("didFailWithError")
      guard let webview = self.parent.tab.webview else { return }
      let script = """
        navigator.geolocation.getCurrentPosition = function(success, error, options) {
          error({
            code: 1,
            message: 'Location retrieval failed'
          });
        };
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
  /*
   End Coordinator
   */
  }
      
  func makeNSView(context: Context) -> WKWebView {
    guard let webView = tab.webview else {
      return WKWebView()
    }
    
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = true
    webView.isInspectable = true
    webView.setValue(false, forKey: "drawsBackground")
    context.coordinator.setUserAgent(for: webView)
    
    if tab.isTrackerBlocking == nil {
      tab.isTrackerBlocking = service.isTrackerBlocking
      ContentBlockRuleList(webView: webView).updateRules(isBlocking: service.isTrackerBlocking)
    }

    return webView
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    // Tracker Blocking
    if let isTrackerBlocking = tab.isTrackerBlocking, isTrackerBlocking != service.isTrackerBlocking {
      tab.isTrackerBlocking = service.isTrackerBlocking
      ContentBlockRuleList(webView: webView).updateRules(isBlocking: service.isTrackerBlocking)
    }
    
    // Geo Location Global Permission
    if tab.isRequestGeoLocation {
      DispatchQueue.main.async {
        print("request geo location")
        tab.isRequestGeoLocation = false
        tab.isLocationDialogIcon = true
        tab.isLocationDialog = true
        context.coordinator.requestGeoLocationPermission()
      }
    }
    
    // Geo Location Update
    if tab.isUpdateLocation {
      DispatchQueue.main.async {
        tab.isUpdateLocation = false
        context.coordinator.requestLocation()
      }
    }
    
    // SPA Update
    if let url = webView.url, !tab.webviewIsError, isSinglePageUpdate {
      DispatchQueue.main.async {
        isSinglePageUpdate = false
        tab.redirectURLByBrowser(url: url)
      }
      return
    }
    
    // Stop Process
    if tab.stopProcess && tab.pageProgress > 0 && tab.pageProgress < 1 {
      DispatchQueue.main.async {
        webView.stopLoading()
        tab.stopProcess = false
        tab.pageProgress = 1.0
      }
      return
    }
    
    // End webview (Cleanup)
    if tab.isClearWebview {
      DispatchQueue.main.async {
        tab.isClearWebview = false
        webView.stopLoading()
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        context.coordinator.isCleanUpAction = true
      }
      return
    }
    
    // Clear Cookies and Web Storage
    if tab.isClearCookieNStorage {
      DispatchQueue.main.async {
        tab.isClearCookieNStorage = false
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { cookies in
          for cookie in cookies {
            cookieStore.delete(cookie)
          }
        }
        let jsString = """
          window.localStorage.clear();
          window.sessionStorage.clear();
        """
        webView.evaluateJavaScript(jsString, completionHandler: nil)
      }
      return
    }
    
    // Zoom In-Out
    if tab.isZoomDialog && tab.zoomLevel != tab.cacheZoomLevel {
      let jsString = "document.body.style.zoom = '\(tab.zoomLevel)'"
      webView.evaluateJavaScript(jsString, completionHandler: nil)
      tab.cacheZoomLevel = tab.zoomLevel
      return
    }
    
    // History
    if tab.updateWebHistory {
      DispatchQueue.main.async {
        tab.historyBackList = webView.backForwardList.backList
        tab.historyForwardList = webView.backForwardList.forwardList
        tab.updateWebHistory = false
      }
      return
    }
    
    // Find Word
    if !tab.findKeyword.isEmpty && tab.isFindAction {
      DispatchQueue.main.async {
        tab.isFindAction = false
        context.coordinator.searchWebView(webView, findText: tab.findKeyword, isPrev: tab.isFindPrev)
      }
      return
    }
    
    // Interruption due to webview loading error
    if tab.webviewIsError && !tab.isUpdateBySearch {
      return
    }
    
    // Load new requested webview URL
    if webView.url == nil || tab.isUpdateBySearch {
      tab.isUpdateBySearch = false
      tab.webviewIsError = false
      webView.stopLoading()
      context.coordinator.checkedSSLCertificate(url: tab.originURL)
      webView.load(URLRequest(url: tab.originURL))
      return
    }
  }
}

