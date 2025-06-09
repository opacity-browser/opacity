//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI
import WebKit
import SwiftData
import UserNotifications

final class Tab: ObservableObject {
  var id = UUID()
  
  // Init
  @Published var isInit: Bool = false
  @Published var isInitFocus: Bool = false
  @Published var stopProcess: Bool = false
  
  // Settings
  @Published var isSetting: Bool = false
  
  // Error
  @Published var errorPageType: ErrorPageType?
  @Published var errorFailingURL: String = ""
  @Published var showErrorPage: Bool = false
  
  // URL
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
  
  var webviewIsError: Bool = false
  
  @Published var title: String = ""
  @Published var favicon: Image? = nil
  var faviconData: Data? = nil
  var faviconURL: URL? = nil
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  @Published var historySiteList: [HistorySite] = []
  @Published var historySiteDataList: [HistorySite] = []
  @Published var historyBackList: [WKBackForwardListItem] = []
  @Published var historyForwardList: [WKBackForwardListItem] = []
  
  // 통합 히스토리 네비게이션을 위한 현재 인덱스
  @Published var currentHistoryIndex: Int = -1
  
  // 히스토리 네비게이션 중인지 확인하는 플래그
  var isNavigatingInHistory: Bool = false
  
  @Published var pageProgress: Double = 0.0
  
  // GeoLocation
  @Published var isUpdateLocation: Bool = false
  @Published var isRequestGeoLocation: Bool = false
  @Published var isLocationDialog: Bool = true
  @Published var isLocationDialogIcon: Bool = false
  @Published var isLocationDialogByHost: Bool = true
  @Published var isLocationDialogIconByHost: Bool = false
  
  // Notification
  @Published var isNotificationDialogIcon: Bool = false
  @Published var isNotificationPermissionByApp: Bool = false
  @Published var isNotificationPermission: Bool = false
  
  // History
  @Published var updateWebHistory: Bool = false
  
  // Tracker Blocking
  var isTrackerBlocking: Bool?
  
  // Search
  @Published var isEditSearch: Bool = false
  @Published var autoCompleteList: [SearchHistoryGroup] = []
  @Published var autoCompleteVisitList: [VisitHistoryGroup] = []
  @Published var autoCompleteIndex: Int?
  @Published var autoCompleteText: String = ""
  @Published var isChangeByKeyDown: Bool = false
  
  // Find
  @Published var isFindDialog: Bool = false
  @Published var isFindAction: Bool = false
  var isFindPrev: Bool = false
  var findKeyword: String = ""
  
  // SSL
  @Published var isValidCertificate: Bool?
  var certificateSummary: String = ""
  
  // Zoom
  @Published var isZoomDialog: Bool = false
  @Published var zoomLevel: CGFloat = 1.0
  var cacheZoomLevel: CGFloat = 1.0
  
  // Cookies & Storage
  @Published var isClearCookieNStorage: Bool = false
  @Published var cookies: [HTTPCookie] = []
  @Published var localStorage: String = "{}"
  @Published var sessionStorage: String = "{}"
  
  
  lazy var webview: WKWebView? = {
    let config = WKWebViewConfiguration()
    
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    
    config.defaultWebpagePreferences = prefs
    config.setURLSchemeHandler(SchemeHandler(), forURLScheme: "opacity")
    
    let contentController = WKUserContentController()
    let scriptHandler = ScriptHandler(tab: self)
    contentController.add(scriptHandler, name: "opacityBrowser")
    config.userContentController = contentController
    
    let scriptSource = """
      // notification
      const originalNotification = Notification;
      class OpacityNotification {
        static requestPermission = () => {
          return new Promise((resolve) => {
            window.resolveNotificationPermission = (permission) => {
              window.resolveNotificationPermission = null;
              resolve(permission);
            };
            window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "notificationRequest" });
          });
        };
        constructor(title, options) {
          window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showNotification", value: JSON.stringify({ title: title, options: options })});
          return new originalNotification(title, options);
        }
      };
      Object.defineProperty(OpacityNotification, 'permission', {
        get: () => originalNotification.permission
      });
      window.Notification = OpacityNotification;
    
      // geolocation
      navigator.geolocation.updatePosition = function(lat, lon) {
        if (navigator.geolocation.watchPositionCallback) {
          navigator.geolocation.watchPositionCallback({
            coords: {
              latitude: lat,
              longitude: lon
            }
          });
        }
      };

      navigator.geolocation.watchPosition = function(successCallback, errorCallback, options) {
        navigator.geolocation.watchPositionCallback = successCallback;
      };
    
      navigator.geolocation.clearWatch = function(watchID) {
        navigator.geolocation.watchPositionCallback = null;
      };
    """
    let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    config.userContentController.addUserScript(userScript)
    
    let preferences = WKPreferences()
    preferences.isElementFullscreenEnabled = true
    preferences.setValue(true, forKey: "developerExtrasEnabled")
    config.preferences = preferences
    
    let webView = OpacityWebView(frame: .zero, configuration: config)
    return webView
  }()
  
  init(url: URL = DEFAULT_URL, type: String = "normal") {
    if type == "Settings" {
      self.originURL = url
      self.inputURL = ""
      self.printURL = ""
      self.title = NSLocalizedString("Settings", comment: "")
      self.isSetting = true
      
      // Settings 페이지를 히스토리에 추가
      let settingsHistorySite = HistorySite(
        title: NSLocalizedString("Settings", comment: ""),
        url: URL(string: "opacity://settings")!,
        siteType: .settings
      )
      self.historySiteList.append(settingsHistorySite)
      self.historySiteDataList.append(settingsHistorySite)
      self.currentHistoryIndex = 0
      
    } else if url == EMPTY_URL {
      self.originURL = url
      self.inputURL = ""
      self.printURL = ""
      self.title = NSLocalizedString("New Tab", comment: "")
      self.isInit = true
      
      // New Tab 페이지를 히스토리에 추가
      let newTabHistorySite = HistorySite(
        title: NSLocalizedString("New Tab", comment: ""),
        url: URL(string: "opacity://new-tab")!,
        siteType: .newTab
      )
      self.historySiteList.append(newTabHistorySite)
      self.historySiteDataList.append(newTabHistorySite)
      self.currentHistoryIndex = 0
      
    } else {
      let stringURL = String(describing: url)
      let shortStringURL = StringURL.shortURL(url: stringURL)
      
      self.originURL = url
      self.inputURL = stringURL
      self.printURL = shortStringURL
      self.title = shortStringURL
    }
    
    DispatchQueue.main.async {
      self.setDomainPermission(url)
    }
  }
  
  @MainActor func setDomainPermission(_ url: URL) {
    self.checkNotificationAuthorization { enabled in
      if let host = url.host, enabled {
        self.isNotificationPermissionByApp = true
        let descriptor = FetchDescriptor<DomainPermission>(
          predicate: #Predicate { $0.domain == host }
        )
        do {
          if let domainNotification = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
            switch domainNotification.permission {
              case DomainPermissionType.notification.rawValue:
                self.isNotificationPermission = !domainNotification.isDenied
              default:
                return
            }
          } else {
            self.isNotificationPermission = false
          }
        } catch {
          print("Model Container Error")
        }
      } else {
        self.isNotificationPermissionByApp = false
      }
    }
  }
  
  func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        switch settings.authorizationStatus {
          case .authorized, .provisional:
            completion(true)
          case .denied:
            completion(false)
          case .notDetermined:
            completion(false)
          @unknown default:
            completion(false)
        }
      }
    }
  }
  
  @Published var isClearWebview: Bool = false
  
  var complateCleanUpWebview: (() -> Void)?
  
  func closeTab(completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      self.complateCleanUpWebview = completion
      
      if self.isInit || self.isSetting || self.showErrorPage {
        completion()
        return
      }
      
      self.isClearWebview = true
    }
  }
  
  func clearPermission() {
    DispatchQueue.main.async {
      self.isLocationDialogIcon = false
      self.isNotificationDialogIcon = false
    }
  }
  
  func clearAutoComplete() {
    DispatchQueue.main.async {
      self.autoCompleteList = []
      self.autoCompleteVisitList = []
      self.autoCompleteIndex = nil
      self.isChangeByKeyDown = false
    }
  }
  
  @MainActor func changeKeywordToURL(_ keyword: String) -> String {
    var newURL = keyword
    if StringURL.checkURL(url: newURL) {
      if !newURL.contains("://") {
        newURL = "https://\(newURL)"
      }
    } else {
      let descriptor = FetchDescriptor<GeneralSetting>()
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          let searchEngine = browserSettings.searchEngine
          let searchEngineData = SEARCH_ENGINE_LIST.first(where: { $0.name == searchEngine })
          if let searchEngineUrlString = searchEngineData?.searchUrlString {
            return searchEngineUrlString + newURL
          }
        }
      } catch {
        print("Error get browser settings")
      }
      newURL = "https://www.google.com/search?q=\(newURL)"
    }
    return newURL
  }
  
  @MainActor func searchInSearchBar(_ searchKeyword: String? = nil) {
    var keyword = ""
    if let searchKeyword = searchKeyword {
      keyword = searchKeyword
    } else {
      keyword = self.inputURL
      if let choiceIndex = self.autoCompleteIndex, self.autoCompleteList.count > 0,  choiceIndex == 0 {
        keyword = self.autoCompleteList[0].searchText
      }
    }
    Task { @MainActor in
      SearchManager.addSearchHistory(keyword)
    }
    
    let newURL = self.changeKeywordToURL(keyword)
    
    if self.isSetting {
      self.isSetting = false
    }
    
    self.updateURLBySearch(url: URL(string: newURL)!)
  }
  
  func updateURLBySearch(url: URL) {
    DispatchQueue.main.async {
      // 현재 페이지가 특수 페이지인 경우 히스토리 확인
      if self.isInit || self.isSetting || self.showErrorPage {
        // 이미 해당 특수 페이지가 현재 인덱스에 있는지 확인
        let needsToAddCurrentPage: Bool
        if self.currentHistoryIndex >= 0 && self.currentHistoryIndex < self.historySiteList.count {
          let currentSite = self.historySiteList[self.currentHistoryIndex]
          needsToAddCurrentPage = !(
            (self.isInit && currentSite.siteType == .newTab) ||
            (self.isSetting && currentSite.siteType == .settings) ||
            (self.showErrorPage && currentSite.siteType == .errorPage)
          )
        } else {
          needsToAddCurrentPage = true
        }
        
        if needsToAddCurrentPage {
          if self.isInit {
            let newTabSite = HistorySite(
              title: NSLocalizedString("New Tab", comment: ""),
              url: URL(string: "opacity://new-tab")!,
              siteType: .newTab
            )
            self.addToHistory(newTabSite)
          } else if self.isSetting {
            let settingsSite = HistorySite(
              title: NSLocalizedString("Settings", comment: ""),
              url: URL(string: "opacity://settings")!,
              siteType: .settings
            )
            self.addToHistory(settingsSite)
          }
        }
      }
      
      self.isInit = false
      self.isSetting = false
      self.isUpdateBySearch = true
      self.originURL = url
      self.inputURL = StringURL.setInputURL(url)
      self.printURL = StringURL.setPrintURL(url)
      self.title = StringURL.setTitleURL(url)
      self.favicon = nil
      self.isEditSearch = false
      self.isValidCertificate = nil
      self.certificateSummary = ""
      self.clearAutoComplete()
      self.clearPermission()
      self.setDomainPermission(url)
      
      // 에러 페이지 상태 초기화
      self.showErrorPage = false
      self.errorPageType = nil
      self.errorFailingURL = ""
      self.webviewIsError = false
    }
  }
  
  func redirectURLByBrowser(url: URL) {
    self.originURL = url
    self.inputURL = StringURL.setInputURL(url)
    self.printURL = StringURL.setPrintURL(url)
  }
  
  func updateURLByBrowser(url: URL, isClearCertificate: Bool) {
    DispatchQueue.main.async {
      self.isInit = false
      self.originURL = url
      self.inputURL = StringURL.setInputURL(url)
      self.printURL = StringURL.setPrintURL(url)
      self.isEditSearch = false
      self.clearPermission()
      self.setDomainPermission(url)
      
      if isClearCertificate {
        self.isUpdateBySearch = true
        self.webviewIsError = false
        self.isValidCertificate = nil
        self.certificateSummary = ""
      }
    }
  }
  
  func loadFavicon(url: URL?) {
    if let url = url {
      URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, let uiImage = NSImage(data: data) else {
          DispatchQueue.main.async {
            self.favicon = nil
          }
          return
        }
        DispatchQueue.main.async {
          self.faviconData = data
          withAnimation {
            self.favicon = Image(nsImage: uiImage)
          }
        }
      }.resume()
    } else {
      DispatchQueue.main.async {
        self.favicon = nil
      }
    }
  }
  
  // MARK: - 통합 히스토리 네비게이션
  
  var canGoBackInHistory: Bool {
    return currentHistoryIndex > 0 && currentHistoryIndex < historySiteList.count
  }
  
  var canGoForwardInHistory: Bool {
    return currentHistoryIndex >= 0 && currentHistoryIndex < historySiteList.count - 1
  }
  
  func goBackInHistory(browser: Browser) {
    guard canGoBackInHistory else { return }
    currentHistoryIndex -= 1
    navigateToHistoryIndex(currentHistoryIndex, browser: browser)
  }
  
  func goForwardInHistory(browser: Browser) {
    guard canGoForwardInHistory else { return }
    currentHistoryIndex += 1
    navigateToHistoryIndex(currentHistoryIndex, browser: browser)
  }
  
  func navigateToHistoryIndex(_ index: Int, browser: Browser) {
    guard index >= 0 && index < historySiteList.count else { return }
    
    // 히스토리 네비게이션 중임을 표시
    isNavigatingInHistory = true
    
    // 현재 인덱스 업데이트
    currentHistoryIndex = index
    
    let historySite = historySiteList[index]
    
    switch historySite.siteType {
    case .newTab:
      DispatchQueue.main.async {
        self.isInit = true
        self.isSetting = false
        self.showErrorPage = false
        self.originURL = URL(string: "about:blank")!
        self.inputURL = ""
        self.printURL = ""
        self.title = NSLocalizedString("New Tab", comment: "")
        self.isNavigatingInHistory = false
        
        // 네비게이션 상태 업데이트
        self.isBack = self.canGoBackInHistory
        self.isForward = self.canGoForwardInHistory
      }
      
    case .settings:
      DispatchQueue.main.async {
        self.isInit = false
        self.isSetting = true
        self.showErrorPage = false
        self.originURL = URL(string: "opacity://settings")!
        self.inputURL = ""
        self.printURL = ""
        self.title = NSLocalizedString("Settings", comment: "")
        self.isNavigatingInHistory = false
        
        // 네비게이션 상태 업데이트
        self.isBack = self.canGoBackInHistory
        self.isForward = self.canGoForwardInHistory
      }
      
    case .errorPage:
      DispatchQueue.main.async {
        self.isInit = false
        self.isSetting = false
        self.showErrorPage = true
        self.errorPageType = historySite.errorType
        self.errorFailingURL = historySite.url.absoluteString
        self.originURL = historySite.url
        self.inputURL = historySite.url.absoluteString
        self.printURL = historySite.url.absoluteString
        self.title = historySite.title
        self.isNavigatingInHistory = false
        
        // 네비게이션 상태 업데이트
        self.isBack = self.canGoBackInHistory
        self.isForward = self.canGoForwardInHistory
      }
      
    case .webPage:
      // 일반 웹페이지의 경우
      DispatchQueue.main.async {
        self.isInit = false
        self.isSetting = false
        self.showErrorPage = false
        self.webviewIsError = false
        self.errorPageType = nil
        self.errorFailingURL = ""
        
        // URL과 상태 업데이트
        self.originURL = historySite.url
        self.inputURL = StringURL.setInputURL(historySite.url)
        self.printURL = StringURL.setPrintURL(historySite.url)
        self.title = historySite.title
        self.isUpdateBySearch = true
        
        // WebView가 있으면 해당 URL로 이동
        if let webview = self.webview {
          webview.load(URLRequest(url: historySite.url))
        }
      }
    }
  }
  
  func addToHistory(_ historySite: HistorySite) {
    // 현재 인덱스 이후의 히스토리 제거 (새로운 페이지로 이동할 때)
    if currentHistoryIndex >= 0 && currentHistoryIndex < historySiteList.count - 1 {
      historySiteList.removeSubrange((currentHistoryIndex + 1)...)
      historySiteDataList = historySiteList // 동기화
    }
    
    // 새 페이지 추가
    historySiteList.append(historySite)
    historySiteDataList.append(historySite)
    currentHistoryIndex = historySiteList.count - 1
    
    // isBack/isForward 상태 업데이트
    DispatchQueue.main.async {
      self.isBack = self.canGoBackInHistory
      self.isForward = self.canGoForwardInHistory
    }
  }
}
