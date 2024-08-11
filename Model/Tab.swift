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

enum WebViewErrorType {
  case notFindHost
  case notConnectHost
  case notConnectInternet
  case occurredSSLError
  case blockedContent
  case unknown
  case noError
}

final class Tab: ObservableObject {
  var id = UUID()
  
  @Published var isInit: Bool = false
  @Published var isInitFocus: Bool = false
  @Published var stopProcess: Bool = false
  
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
  
  var webviewIsError: Bool = false
  var webviewErrorType: WebViewErrorType = .noError
  
  @Published var title: String = ""
  @Published var favicon: Image? = nil
  var faviconData: Data? = nil
  var faviconURL: URL? = nil
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  @Published var historySiteDataList: [HistorySite] = []
  @Published var historyBackList: [WKBackForwardListItem] = []
  @Published var historyForwardList: [WKBackForwardListItem] = []
  
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
  
  init(url: URL = DEFAULT_URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    self.originURL = url
    self.inputURL = stringURL
    self.printURL = shortStringURL
    self.title = shortStringURL
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
    SearchManager.addSearchHistory(keyword)
    
    let newURL = self.changeKeywordToURL(keyword)
    self.updateURLBySearch(url: URL(string: newURL)!)
  }
  
  func updateURLBySearch(url: URL) {
    DispatchQueue.main.async {
      self.isInit = false
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
}
