//
//  NavigationCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import WebKit

class NavigationCoordinator: NSObject, WKNavigationDelegate {
  var parent: MainWebView!
  var sslCertificateCoordinator: SSLCertificateCoordinator!
  var geoLocationCoordinator: GeoLocationCoordinator!
  
  var cacheErrorURL: URL?
  var reloadAttemptCount = 0
  var isCleanUpAction: Bool = false
  private var urlObservation: NSKeyValueObservation?
  private var titleObservation: NSKeyValueObservation?
  
  // isSinglePageUpdate 상태를 내부에서 관리
  private var shouldTriggerSinglePageUpdate: Bool = false
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
    setupObservers()
  }
  
  private func setupObservers() {
    guard let webview = parent.tab.webview else { return }
    // canGoBack/canGoForward 옵저버 제거 - 통합 히스토리 시스템 사용
    urlObservation = webview.observe(\.url, options: .new) { [weak self] webView, change in
      if let newURL = change.newValue {
        self?.handleURLChange(newURL)
      }
    }
    titleObservation = webview.observe(\.title, options: .new) { [weak self] webView, change in
      if let newTitle = change.newValue, let title = newTitle, !title.isEmpty {
        DispatchQueue.main.async {
          print("Title changed via KVO: \(title)")
          self?.updateTabTitle(webView: webView, title: title)
        }
      }
    }
  }
  
  private func updateTabTitle(webView: WKWebView, title: String) {
    parent.tab.title = title
    
    if let webviewURL = webView.url {
      if let historySite = parent.tab.historySiteList.first(where: { $0.url == webviewURL }) {
        historySite.title = title
      }
    }
  }
  
  func cleanup() {
    urlObservation?.invalidate()
    titleObservation?.invalidate()
  }
  
  private func normalizeURL(_ url: String) -> String {
    return url.hasSuffix("/") ? String(url.dropLast()) : url
  }
  
  private func handleURLChange(_ url: URL?) {
    guard let url = url,
          normalizeURL(url.absoluteString) != normalizeURL(parent.tab.originURL.absoluteString) else { return }
    shouldTriggerSinglePageUpdate = true
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    // KVO 관찰자는 더 이상 isBack/isForward를 업데이트하지 않음
    // 통합 히스토리 시스템이 이 상태를 관리함
  }
  
  func setUserAgent(for webView: WKWebView) {
    webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
      guard let userAgent = result as? String else { return }
      
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
  
  // 반환값으로 isSinglePageUpdate 상태를 알려줌
  func handleNavigationUpdates(webView: WKWebView, currentIsSinglePageUpdate: Bool) -> Bool {
    var newIsSinglePageUpdate = currentIsSinglePageUpdate
    
    // SPA 업데이트 처리
    if let url = webView.url, !parent.tab.webviewIsError, shouldTriggerSinglePageUpdate {
      self.getWebViewDocumentTitle(webView: webView)
      self.getWebViewFavicon(webView: webView) { faviconURL in
        let historySite = HistorySite(title: self.parent.tab.title, url: url, siteType: .webPage)
        if let faviconURL = faviconURL {
          historySite.loadFavicon(url: faviconURL)
          // 정리 작업 중이 아닐 때만 SPA 방문기록 추가
          if !self.isCleanUpAction {
            Task {
              let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
              VisitManager.addVisitHistory(url: url.absoluteString, title: self.parent.tab.title, faviconData: faviconData)
            }
          }
        }
        // SPA 업데이트의 경우 히스토리 네비게이션 중이 아니고 기존 URL과 다른 경우에만 히스토리에 추가
        let shouldAddToHistory = !self.parent.tab.isNavigatingInHistory &&
                               (self.parent.tab.historySiteList.isEmpty || 
                                self.parent.tab.historySiteList.last?.url != url)
        
        if shouldAddToHistory {
          self.parent.tab.addToHistory(historySite)
        }
      }
      
      DispatchQueue.main.async {
        self.parent.tab.redirectURLByBrowser(url: url)
      }
      shouldTriggerSinglePageUpdate = false
      newIsSinglePageUpdate = false
      return newIsSinglePageUpdate
    }
    
    // 중지 프로세스 처리
    if parent.tab.stopProcess && parent.tab.pageProgress > 0 && parent.tab.pageProgress < 1 {
      DispatchQueue.main.async {
        webView.stopLoading()
        self.parent.tab.stopProcess = false
        self.parent.tab.pageProgress = 1.0
      }
      return newIsSinglePageUpdate
    }
    
    // WebView 정리 처리
    if parent.tab.isClearWebview {
      handleWebViewCleanup(webView: webView)
      return newIsSinglePageUpdate
    }
    
    // 새 URL 로드 처리
    if webView.url == nil || parent.tab.isUpdateBySearch {
      handleNewURLLoad(webView: webView)
    }
    
    return newIsSinglePageUpdate
  }
  
  private func handleWebViewCleanup(webView: WKWebView) {
    DispatchQueue.main.async {
      self.parent.tab.isClearWebview = false
      webView.stopLoading()
      
      // WebView title 초기화 (악성 제목 방지)
      self.parent.tab.title = ""
      
      webView.load(URLRequest(url: URL(string: "about:blank")!))
      self.isCleanUpAction = true
    }
  }
  
  private func handleNewURLLoad(webView: WKWebView) {
    if parent.tab.isInit {
        return
      }
      
      parent.tab.isUpdateBySearch = false
      parent.tab.webviewIsError = false
      webView.stopLoading()
      sslCertificateCoordinator.checkedSSLCertificate(url: parent.tab.originURL)
      webView.load(URLRequest(url: parent.tab.originURL))
  }
  
  // MARK: - WKNavigationDelegate 메서드들
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    print("didStartProvisionalNavigation")
    if !isCleanUpAction {
      DispatchQueue.main.async {
        self.parent.tab.pageProgress = webView.estimatedProgress
      }
    }
  }
  
  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    print("didCommit")
    guard let webviewURL = webView.url else { return }
    
    if webviewURL != parent.tab.originURL {
      if let errorContentURL = cacheErrorURL, parent.tab.webviewIsError {
        sslCertificateCoordinator.checkedSSLCertificate(url: errorContentURL)
        parent.tab.redirectURLByBrowser(url: errorContentURL)
      } else {
        sslCertificateCoordinator.checkedSSLCertificate(url: webviewURL)
        parent.tab.redirectURLByBrowser(url: webviewURL)
      }
    } else {
      sslCertificateCoordinator.checkedSSLCertificate(url: webviewURL)
    }
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let requestURL = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }
    
    // Command 키와 함께 클릭한 경우 새 탭에서 열기
    if navigationAction.modifierFlags.contains(.command) {
      parent.browser.newTab(requestURL)
      decisionHandler(.cancel)
      return
    }
    
    // 다운로드 처리
    if navigationAction.shouldPerformDownload {
      decisionHandler(.download)
      return
    }
    
    decisionHandler(.allow)
  }
  
  func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    print("didReceiveServerRedirectForProvisionalNavigation")
    guard let webviewURL = webView.url, webviewURL != parent.tab.originURL else { return }
    
    DispatchQueue.main.async {
      self.sslCertificateCoordinator.checkedSSLCertificate(url: webviewURL)
      self.parent.tab.redirectURLByBrowser(url: webviewURL)
    }
  }
  
  @MainActor func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("didFinish")
    
    // 정리 작업 처리
    if let completeCleanUpWebview = parent.tab.complateCleanUpWebview, isCleanUpAction {
      handleCleanupCompletion(webView: webView, completion: completeCleanUpWebview)
      return
    }
    
    // YouTube 광고 차단 스크립트 실행
    executeYouTubeAdBlockScript(webView: webView)
    
    // 페이지 로드 완료 처리
    DispatchQueue.main.async {
      self.parent.tab.pageProgress = 1.0
    }
    
    // 히스토리 정리
    cleanupHistory(webView: webView)
    
    // 페이지 데이터 수집
    if !parent.tab.webviewIsError {
      collectPageData(webView: webView)
    }
    
    // GeoLocation 초기화
    geoLocationCoordinator.initGeoPositions()
    
    // Hash 변경 리스너 추가
    setupHashChangeListener(webView: webView)
    
    // 페이지 정보 수집
    collectPageInfo(webView: webView)
    
    // 리로드 카운터 초기화
    reloadAttemptCount = 0
  }
  
  private func handleCleanupCompletion(webView: WKWebView, completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      webView.stopLoading()
      webView.navigationDelegate = nil
      webView.uiDelegate = nil
      webView.configuration.userContentController.removeAllScriptMessageHandlers()
      webView.removeFromSuperview()
      self.parent.tab.webview = nil
      URLCache.shared.removeAllCachedResponses()
      completion()
    }
  }
  
  private func executeYouTubeAdBlockScript(webView: WKWebView) {
    guard let webviewURL = webView.url,
          let host = webviewURL.host,
          let scriptURL = Bundle.main.url(forResource: "removeAdblockThing", withExtension: "js"),
          parent.service.isTrackerBlocking,
          host.contains("youtube.com") else { return }
    
    do {
      let scriptContent = try String(contentsOf: scriptURL, encoding: .utf8)
      webView.evaluateJavaScript(scriptContent, completionHandler: nil)
    } catch {
      print("Failed to load JavaScript file: \(error.localizedDescription)")
    }
  }
  
  private func cleanupHistory(webView: WKWebView) {
    // 통합 히스토리 시스템에서는 히스토리 정리를 하지 않음
    // WebKit의 히스토리와 독립적으로 관리
  }
  
  private func collectPageData(webView: WKWebView) {
    // 쿠키 수집
    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
      var cacheCookies: [HTTPCookie] = []
      let currentURL = webView.url
      for cookie in cookies {
        if let url = currentURL, cookie.domain.range(of: url.host ?? "") != nil {
          cacheCookies.append(cookie)
        }
      }
      DispatchQueue.main.async {
        self.parent.tab.cookies = cacheCookies
      }
    }
    
    // localStorage 수집
    webView.evaluateJavaScript("JSON.stringify(window.localStorage)") { (result, error) in
      if let localStorage = result as? String {
        DispatchQueue.main.async {
          self.parent.tab.localStorage = localStorage
        }
      }
    }
    
    // sessionStorage 수집
    webView.evaluateJavaScript("JSON.stringify(window.sessionStorage)") { (result, error) in
      if let sessionStorage = result as? String {
        DispatchQueue.main.async {
          self.parent.tab.sessionStorage = sessionStorage
        }
      }
    }
  }
  
  private func setupHashChangeListener(webView: WKWebView) {
    webView.evaluateJavaScript("""
      window.addEventListener('hashchange', function() {
        window.webkit.messageHandlers.opacityBrowser.postMessage({
          name: "hashChange",
          value: window.location.href
        });
      });
    """)
  }
  
  private func collectPageInfo(webView: WKWebView) {
    let group = DispatchGroup()
    
    // 페이지 제목 수집
    getWebViewDocumentTitle(webView: webView, group: group)
    
    // 파비콘 수집
    getWebViewDocumentFavicon(webView: webView, group: group)
    
    group.notify(queue: .main) {
      if let currentURL = webView.url {
        // 이미 히스토리에 현재 URL이 있는지 확인 (중복 방지)
        let shouldAddToHistory = self.parent.tab.historySiteList.isEmpty || 
                                self.parent.tab.historySiteList.last?.url != self.parent.tab.originURL
        
        let historySite = HistorySite(title: self.parent.tab.title, url: self.parent.tab.originURL, siteType: .webPage)
        if let faviconURL = self.parent.tab.faviconURL {
          historySite.loadFavicon(url: faviconURL)
          // 정리 작업 중이 아닐 때만 방문기록 추가
          if !self.isCleanUpAction {
            Task {
              let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
              VisitManager.addVisitHistory(url: currentURL.absoluteString, title: self.parent.tab.title, faviconData: faviconData)
            }
          }
        }
        
        // 히스토리 네비게이션 중이 아닌 경우에만 히스토리에 추가
        if !self.parent.tab.isNavigatingInHistory && shouldAddToHistory {
          self.parent.tab.addToHistory(historySite)
        } else {
          // 기존 히스토리 아이템의 파비콘과 제목 업데이트
          if let lastHistorySite = self.parent.tab.historySiteList.last,
             lastHistorySite.url == self.parent.tab.originURL {
            lastHistorySite.title = self.parent.tab.title
            if let faviconURL = self.parent.tab.faviconURL {
              lastHistorySite.loadFavicon(url: faviconURL)
            }
          }
        }
        
        // 웹페이지 로드 완료 후 플래그 리셋 및 네비게이션 상태 업데이트
        if self.parent.tab.isNavigatingInHistory {
          self.parent.tab.isNavigatingInHistory = false
          // 네비게이션 상태 업데이트
          DispatchQueue.main.async {
            self.parent.tab.isBack = self.parent.tab.canGoBackInHistory
            self.parent.tab.isForward = self.parent.tab.canGoForwardInHistory
          }
        }
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
      }
    }
  }
  
  private func getWebViewFavicon(webView: WKWebView, completion: @escaping (URL?) -> Void) {
      webView.evaluateJavaScript("""
        (function() {
          var baseURI = document.baseURI;
          var icons = [];
          
          // 다양한 favicon 링크 태그들 수집
          var linkTags = document.querySelectorAll('link[rel*="icon"]');
          for (var i = 0; i < linkTags.length; i++) {
            var href = linkTags[i].getAttribute('href');
            var sizes = linkTags[i].getAttribute('sizes');
            var type = linkTags[i].getAttribute('type');
            var rel = linkTags[i].getAttribute('rel');
            
            if (href) {
              icons.push({
                href: href,
                sizes: sizes || '',
                type: type || '',
                rel: rel || ''
              });
            }
          }
          
          return {
            baseURI: baseURI,
            icons: icons
          };
        })()
      """) { (response, error) in
        guard let result = response as? [String: Any],
              let baseURI = result["baseURI"] as? String,
              let icons = result["icons"] as? [[String: String]],
              let base = URL(string: baseURI) else {
          completion(self.getDefaultFaviconURL(from: webView))
          return
        }
        
        // 최적의 favicon 선택
        let bestIconHref = self.selectBestFavicon(from: icons)
        
        if let href = bestIconHref {
          let faviconURL = self.constructFaviconURL(href: href, baseURL: base)
          completion(faviconURL)
        } else {
          completion(self.getDefaultFaviconURL(from: webView))
        }
      }
  }

  private func selectBestFavicon(from icons: [[String: String]]) -> String? {
    guard !icons.isEmpty else { return nil }
    
    // apple-touch-icon이 아닌 아이콘들만 필터링
    let nonAppleIcons = icons.filter { icon in
      let rel = icon["rel"] ?? ""
      return !rel.contains("apple-touch-icon")
    }
    
    // 1순위: 32x32 크기 (apple-touch-icon 제외)
    if let icon32 = nonAppleIcons.first(where: { icon in
      let sizes = icon["sizes"] ?? ""
      return sizes.contains("32x32") || sizes.contains("32")
    }) {
      return icon32["href"]
    }
    
    // 2순위: 크기가 명시된 것 중 32에 가장 가까운 것 (apple-touch-icon 제외)
    let iconsWithSize = nonAppleIcons.compactMap { icon -> (String, Int)? in
      guard let href = icon["href"],
            let size = extractLargestIconSize(icon["sizes"] ?? "") else {
        return nil
      }
      return (href, size)
    }
    
    if !iconsWithSize.isEmpty {
      // 32보다 크거나 같은 것 중 가장 작은 것
      let preferredIcons = iconsWithSize.filter { $0.1 >= 32 }
      if let closest = preferredIcons.min(by: { $0.1 < $1.1 }) {
        return closest.0
      }
      
      // 32보다 작은 것 중 가장 큰 것
      if let largest = iconsWithSize.max(by: { $0.1 < $1.1 }) {
        return largest.0
      }
    }
    
    // 3순위: PNG 타입 (apple-touch-icon 제외)
    if let pngIcon = nonAppleIcons.first(where: { icon in
      let type = icon["type"] ?? ""
      return type.contains("png")
    }) {
      return pngIcon["href"]
    }
    
    // 4순위: SVG 타입 (apple-touch-icon 제외)
    if let svgIcon = nonAppleIcons.first(where: { icon in
      let type = icon["type"] ?? ""
      return type.contains("svg")
    }) {
      return svgIcon["href"]
    }
    
    // 5순위: 일반 아이콘 (apple-touch-icon 제외)
    if let normalIcon = nonAppleIcons.first {
      return normalIcon["href"]
    }
    
    // 6순위: apple-touch-icon (마지막 순위)
    if let appleIcon = icons.first(where: { icon in
      let rel = icon["rel"] ?? ""
      return rel.contains("apple-touch-icon")
    }) {
      return appleIcon["href"]
    }
    
    return nil
  }

  private func extractLargestIconSize(_ sizeString: String) -> Int? {
    // "16x16", "32x32", "16x16 32x32" 등의 형태에서 가장 큰 크기 추출
    let pattern = #"(\d+)x\d+"#
    let regex = try? NSRegularExpression(pattern: pattern)
    let matches = regex?.matches(in: sizeString, range: NSRange(sizeString.startIndex..., in: sizeString)) ?? []
    
    var sizes: [Int] = []
    for match in matches {
      if let range = Range(match.range(at: 1), in: sizeString),
         let size = Int(sizeString[range]) {
        sizes.append(size)
      }
    }
    
    return sizes.max()
  }

  private func getDefaultFaviconURL(from webView: WKWebView) -> URL? {
    guard let webViewURL = webView.url,
          let scheme = webViewURL.scheme,
          let host = webViewURL.host else { return nil }
    
    return URL(string: "\(scheme)://\(host)/favicon.ico")
  }

  private func constructFaviconURL(href: String, baseURL: URL) -> URL? {
    let cleanedHref = href.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if cleanedHref.hasPrefix("http://") || cleanedHref.hasPrefix("https://") {
      return URL(string: cleanedHref)
    } else if cleanedHref.hasPrefix("//") {
      return URL(string: "https:\(cleanedHref)")
    } else {
      return URL(string: cleanedHref, relativeTo: baseURL)
    }
  }
  
  private func getWebViewDocumentFavicon(webView: WKWebView, group: DispatchGroup? = nil) {
    group?.enter()
    
    self.getWebViewFavicon(webView: webView) { faviconURL in
      DispatchQueue.main.async {
        self.parent.tab.faviconURL = faviconURL
        self.parent.tab.loadFavicon(url: faviconURL)
        
        // VisitHistoryGroup의 파비콘도 업데이트
        if let faviconURL = faviconURL, let currentURL = webView.url {
          Task {
            let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
            if let faviconData = faviconData {
              VisitManager.updateVisitHistoryGroupFavicon(url: currentURL.absoluteString, faviconData: faviconData)
            }
          }
        }
        
        group?.leave()
      }
    }
  }
  
  private func handleDefaultFavicon(for url: URL?) {
    guard let webviewURL = url, let scheme = webviewURL.scheme, let host = webviewURL.host else { return }
    
    let faviconURL = URL(string: "\(scheme)://\(host)/favicon.ico")!
    DispatchQueue.main.async {
      self.parent.tab.faviconURL = faviconURL
      self.parent.tab.loadFavicon(url: faviconURL)
      
      // VisitHistoryGroup의 파비콘도 업데이트
      Task {
        let faviconData = await VisitHistoryGroup.getFaviconData(url: faviconURL)
        if let faviconData = faviconData {
          VisitManager.updateVisitHistoryGroupFavicon(url: webviewURL.absoluteString, faviconData: faviconData)
        }
      }
    }
  }
  
  // MARK: - 에러 처리 메서드들
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    print("didFailProvisionalNavigation")
    parent.tab.pageProgress = 1.0
    if (error as NSError).code == NSURLErrorCancelled {
      return
    }
    handleWebViewErrorWithSwiftUI(webView: webView, error: error)
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("didFail")
    parent.tab.pageProgress = 1.0
    if (error as NSError).code == NSURLErrorCancelled {
      getWebViewDocumentTitle(webView: webView)
      getWebViewDocumentFavicon(webView: webView)
      return
    }
    handleWebViewErrorWithSwiftUI(webView: webView, error: error)
  }
  
  private func handleWebViewErrorWithSwiftUI(webView: WKWebView, error: Error) {
    let nsError = error as NSError
    print("handleWebViewError with SwiftUI")
    print("Load failed with error: \(error.localizedDescription)")
    
    parent.tab.webviewIsError = true
    guard let failingURL = nsError.userInfo["NSErrorFailingURLKey"] as? URL else { return }
    
    // 이미 에러 페이지를 표시 중이면 리턴
    if parent.tab.showErrorPage {
      return
    }
    
    let errorType: ErrorPageType
    
    switch nsError.code {
      case 104:
        errorType = .blockedContent
      case WebKitErrorFrameLoadInterruptedByPolicyChange:
        print("Frame load interrupted by policy change: \(error.localizedDescription)")
        return
      case NSURLErrorCannotFindHost:
        errorType = .notFindHost
      case NSURLErrorCannotConnectToHost:
        errorType = .notConnectHost
      case NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateHasBadDate:
        errorType = .occurredSSLError
      case NSURLErrorNotConnectedToInternet:
        errorType = .notConnectInternet
      default:
        errorType = .unknown
    }
    
    DispatchQueue.main.async {
      // WebView 로딩 중지
      webView.stopLoading()
      
      self.parent.tab.inputURL = failingURL.absoluteString
      self.parent.tab.printURL = failingURL.absoluteString
      self.parent.tab.errorPageType = errorType
      self.parent.tab.errorFailingURL = failingURL.absoluteString
      self.parent.tab.showErrorPage = true
      
      // 에러 페이지를 히스토리에 추가
      let errorTitle = self.getErrorTitle(for: errorType)
      let errorHistorySite = HistorySite(
        title: errorTitle,
        url: failingURL,
        siteType: .errorPage,
        errorType: errorType
      )
      self.parent.tab.addToHistory(errorHistorySite)
    }
  }
  
  private func getErrorTitle(for errorType: ErrorPageType) -> String {
    switch errorType {
    case .notFindHost:
      return NSLocalizedString("Page not found", comment: "")
    case .notConnectHost:
      return NSLocalizedString("Unable to connect to site", comment: "")
    case .notConnectInternet:
      return NSLocalizedString("No internet connection", comment: "")
    case .occurredSSLError:
      return NSLocalizedString("SSL/TLS certificate error", comment: "")
    case .blockedContent:
      return NSLocalizedString("Blocked content", comment: "")
    case .unknown:
      return NSLocalizedString("Unknown error", comment: "")
    }
  }
}
