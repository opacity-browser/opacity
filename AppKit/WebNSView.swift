//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit
import CoreLocation
import ASN1Decoder
import Security

struct WebNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, URLSessionDelegate, CLLocationManagerDelegate {
    var parent: WebNSView
    var locationManager: CLLocationManager?
    var cacheErrorURL: URL?
    var isCleanUpAction: Bool = false
    
    init(_ parent: WebNSView) {
      self.parent = parent
      super.init()
      if let webview = self.parent.tab.webview {
        webview.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        webview.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
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

    deinit {
      if let webview = self.parent.tab.webview {
        webview.removeObserver(self, forKeyPath: "canGoBack")
        webview.removeObserver(self, forKeyPath: "canGoForward")
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
        let errorHosts = ["blocked-content", "not-find-host", "not-connect-host", "occurred-ssl-error", "not-connect-internet", "unknown"]
        if let webviewURL = webView.url, let host = webviewURL.host, webviewURL.scheme == "opacity", parent.tab.webviewIsError == false, errorHosts.contains(host) {
          self.parent.tab.webviewIsError = true
          if host == "blocked-content" {
            self.parent.tab.webviewErrorType = .blockedContent
          }
          if host == "not-find-host" {
            self.parent.tab.webviewErrorType = .notFindHost
          }
          if host == "not-connect-host" {
            self.parent.tab.webviewErrorType = .notConnectHost
          }
          if host == "occurred-ssl-error" {
            self.parent.tab.webviewErrorType = .occurredSSLError
          }
          if host == "not-connect-internet" {
            self.parent.tab.webviewErrorType = .notConnectInternet
          }
          if host == "unknown" {
            self.parent.tab.webviewErrorType = .unknown
          }
        }
      }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
      print("didCommit")
      if let webviewURL = webView.url, webviewURL != self.parent.tab.originURL {
        if let errorContnetURL = self.cacheErrorURL, self.parent.tab.webviewIsError {
          self.checkedSSLCertificate(url: errorContnetURL)
          self.parent.tab.redirectURLByBrowser(url: errorContnetURL)
        } else {
          self.checkedSSLCertificate(url: webviewURL)
          self.parent.tab.redirectURLByBrowser(url: webviewURL)
        }
      }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//      print("webView.url: \(webView.url)")
//      print("request.url: \(navigationAction.request.url)")
//      print("----")
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
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
      print("didReceiveServerRedirectForProvisionalNavigation")
      if let webviewURL = webView.url, webviewURL != parent.tab.originURL {
        DispatchQueue.main.async {
          self.checkedSSLCertificate(url: webviewURL)
          self.parent.tab.redirectURLByBrowser(url: webviewURL)
        }
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      print("didFinish")
      if let complateCleanUpWebview = self.parent.tab.complateCleanUpWebview, isCleanUpAction {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
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
        }
        return
      }
      
      DispatchQueue.main.async {
        self.parent.tab.pageProgress = 1.0
      }
      
      let historyList = webView.backForwardList.backList + webView.backForwardList.forwardList
      let historyUrlList = historyList.compactMap { $0.url }
      
      self.parent.tab.historySiteDataList = self.parent.tab.historySiteDataList.filter { item in
        historyUrlList.contains(item.url)
      }
      
      if parent.tab.webviewIsError {
        print("error page init script")
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let headTitle = parent.tab.printURL
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
          case .occurredSSLError:
            title = NSLocalizedString("SSL/TLS certificate error", comment: "")
            message = NSLocalizedString("A secure connection cannot be made because the certificate is not valid.", comment: "")
            break
          case .blockedContent:
            title = NSLocalizedString("Blocked content", comment: "")
            message = NSLocalizedString("This content is blocked. To use the service, you must lower or turn off tracker blocking.", comment: "")
            break
          case .unknown:
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
            headTitle: '\(headTitle)',
            title: '\(title)',
            refreshBtn: '\(refreshBtn)',
            message: '\(message)'
          })
         """)
        }
        
        parent.tab.webviewIsError = false
      } else {// not error
        // Fetch Cookie
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
          var cacheCookies: [HTTPCookie] = []
          for cookie in cookies {
            cacheCookies.append(cookie)
          }
          DispatchQueue.main.async {
            self.parent.tab.cookies = cacheCookies
          }
        }
        // Fetch localStorage
        webView.evaluateJavaScript("JSON.stringify(localStorage)") { (result, error) in
          if let localStorage = result as? String {
            DispatchQueue.main.async {
              self.parent.tab.localStorage = localStorage
            }
          }
        }
        // Fetch sessionStorage
        webView.evaluateJavaScript("JSON.stringify(sessionStorage)") { (result, error) in
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
        let unwantedCharacters = CharacterSet(charactersIn: "\n\r\t")
        guard let href = response as? String, let currentURL = webView.url, href.components(separatedBy: unwantedCharacters).joined() != "" else {
          if let webviewURL = webView.url, let scheme = webviewURL.scheme, let host = webviewURL.host  {
            if webviewURL.scheme != "opacity" {
              let faviconURL = scheme + "://" + host + "/favicon.ico"
              DispatchQueue.main.async {
                cacheFaviconURL = URL(string: faviconURL)!
                self.parent.tab.loadFavicon(url: URL(string: faviconURL)!)
              }
            }
          }
          group.leave()
          return
        }
      
        let cleanedHref = href.components(separatedBy: unwantedCharacters).joined()
        
        let faviconURL: URL
        if cleanedHref.hasPrefix("http") {
          faviconURL = URL(string: cleanedHref)!
        } else if cleanedHref.hasPrefix("//") {
          faviconURL = URL(string: "https:\(cleanedHref)")!
        } else if cleanedHref.hasPrefix("/") {
          var components = URLComponents(url: currentURL, resolvingAgainstBaseURL: true)!
          
          let splitHref = cleanedHref.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: true)
          let pathPart = String(splitHref[0])
          let queryPart = splitHref.count > 1 ? String(splitHref[1]) : nil
          
          components.path = pathPart
          components.query = queryPart
          
          faviconURL = components.url!
        } else {
          faviconURL = URL(string: cleanedHref, relativeTo: currentURL)!
        }
        
        DispatchQueue.main.async {
          cacheFaviconURL = faviconURL
          self.parent.tab.loadFavicon(url: faviconURL)
          group.leave()
        }
      }
      
      group.notify(queue: .main) {
        if let title = cacheTitle, let currentURL = webView.url {
          let historySite = HistorySite(title: title, url: self.parent.tab.originURL)
          if let faviconURL = cacheFaviconURL {
            historySite.loadFavicon(url: faviconURL)
            Task {
              let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
              await VisitManager.addVisitHistory(url: currentURL.absoluteString, title: title, faviconData: faviconData)
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
        let errorURLBase64: Data = failingURL.absoluteString.data(using: .utf8)!
        
        switch nsError.code {
            //          case NSFileNoSuchFileError:
            //            // 파일을 찾을 수 없음
            //          case NSFileReadNoPermissionError:
            //            // 파일 읽기 권한 없음
            //          case NSFileReadCorruptFileError:
            //            // 손상된 파일
          case 104:
            parent.tab.webviewErrorType = .blockedContent
            if let schemeURL = URL(string:"opacity://blocked-content?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case WebKitErrorFrameLoadInterruptedByPolicyChange:
            print("Frame load interrupted by policy change: \(error.localizedDescription)")
            break
          case NSURLErrorCannotFindHost:
            parent.tab.webviewErrorType = .notFindHost
            if let schemeURL = URL(string:"opacity://not-find-host?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorCannotConnectToHost:
            parent.tab.webviewErrorType = .notConnectHost
            if let schemeURL = URL(string:"opacity://not-connect-host?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorSecureConnectionFailed:
            parent.tab.webviewErrorType = .occurredSSLError
            if let schemeURL = URL(string:"opacity://occurred-ssl-error?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorServerCertificateHasBadDate:
            parent.tab.webviewErrorType = .occurredSSLError
            if let schemeURL = URL(string:"opacity://occurred-ssl-error?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          case NSURLErrorNotConnectedToInternet:
            parent.tab.webviewErrorType = .notConnectInternet
            if let schemeURL = URL(string:"opacity://not-connect-internet?url=\(errorURLBase64.base64EncodedString())") {
              webView.load(URLRequest(url: schemeURL))
            }
            break
          default:
            parent.tab.webviewErrorType = .unknown
            if let schemeURL = URL(string:"opacity://unknown?url=\(errorURLBase64.base64EncodedString())") {
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
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
    
    /*
     Geo Locaiton
     */
    private func initGeoPositions() {
      locationManager = CLLocationManager()
      locationManager!.delegate = self

      switch locationManager!.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
          locationManager!.startUpdatingLocation()
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
    
    private func deniedGeolocation() {
      guard let webview = self.parent.tab.webview else { return }
      let script = """
        navigator.geolocation.getCurrentPosition = function(success, error, options) {
          error({
            code: 1,
            message: 'User Denied Geolocation'
          });
          window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "requestWhenInUseAuthorization" });
        }
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      guard let locationManager = locationManager else { return }
      switch status {
        case .authorizedWhenInUse, .authorizedAlways:
          locationManager.startUpdatingLocation()
          DispatchQueue.main.async {
            self.parent.tab.isLocationDialogIcon = false
          }
          break
        case .denied, .restricted:
          deniedGeolocation()
          break
        default:
          break
      }
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let location = locations.first, let webview = self.parent.tab.webview, let locationManager = locationManager else { return }
  
      let script = """
        navigator.geolocation.getCurrentPosition = function(success, error, options) {
          success({
            coords: {
              latitude: \(location.coordinate.latitude),
              longitude: \(location.coordinate.longitude)
            }
          })
        }
      """
  
      webview.evaluateJavaScript(script, completionHandler: nil)
      locationManager.stopUpdatingLocation()
    }
  
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
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
  
  private func addContentBlockingRules(_ webView: WKWebView) {
    var blockingRules: String = "blockingLevel2Rules"
    if service.blockingLevel == BlockingTrakerList.blockingLight.rawValue {
      blockingRules = "blockingLevel1Rules"
    }
    if service.blockingLevel == BlockingTrakerList.blockingModerate.rawValue {
      blockingRules = "blockingLevel2Rules"
    }
    if service.blockingLevel == BlockingTrakerList.blockingStrong.rawValue {
      blockingRules = "blockingLevel3Rules"
    }
    
    if let rulePath = Bundle.main.path(forResource: blockingRules, ofType: "json"),
       let ruleString = try? String(contentsOfFile: rulePath) {
      WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: ruleString) { ruleList, error in
        if let ruleList = ruleList {
          webView.configuration.userContentController.add(ruleList)
        } else if let error = error {
          print("Error compiling content rule list: \(error)")
        }
      }
    }
  }
  
  private func clearContentBlockingRules() {
    WKContentRuleListStore.default().getAvailableContentRuleListIdentifiers { identifiers in
      if ((identifiers?.contains("ContentBlockingRules")) != nil) {
        WKContentRuleListStore.default().removeContentRuleList(forIdentifier: "ContentBlockingRules") { error in
          if let error = error {
            print("Error removing content rule list: \(error)")
          } else {
            print("Remove blocking tracker")
          }
        }
      }
    }
  }
  
  private func updateBlockingRules(_ webView: WKWebView) {
    clearContentBlockingRules()
    if service.blockingLevel != BlockingTrakerList.blockingNone.rawValue {
      addContentBlockingRules(webView)
    }
  }
      
  func makeNSView(context: Context) -> WKWebView {
    guard let webview = tab.webview else {
      return WKWebView()
    }
    
    webview.navigationDelegate = context.coordinator
    webview.uiDelegate = context.coordinator
    webview.allowsBackForwardNavigationGestures = true
    webview.isInspectable = true
    webview.setValue(false, forKey: "drawsBackground")
    updateBlockingRules(webview)
    
    context.coordinator.setUserAgent(for: webview)
    
    return webview
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    // Stop Process
    if tab.stopProcess && tab.pageProgress > 0 && tab.pageProgress < 1 {
      DispatchQueue.main.async {
        webView.stopLoading()
        self.tab.stopProcess = false
        self.tab.pageProgress = 1.0
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
          localStorage.clear();
          sessionStorage.clear();
        """
        webView.evaluateJavaScript(jsString, completionHandler: nil)
      }
      return
    }
    
    // Geo Location Permission
    if tab.isRequestGeoLocation {
      DispatchQueue.main.async {
        print("request geo location")
        tab.isRequestGeoLocation = false
        tab.isLocationDialogIcon = true
        tab.isLocationDialog = true
        context.coordinator.requestGeoLocationPermission()
      }
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
    
    // Word Search
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
      let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
      let dateFrom = Date(timeIntervalSince1970: 0)
      WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
        webView.stopLoading()
        context.coordinator.checkedSSLCertificate(url: tab.originURL)
        webView.load(URLRequest(url: tab.originURL))
      }
      return
    }
  }
}

