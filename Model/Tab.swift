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
  case unkown
  case noError
}

final class Tab: ObservableObject, Identifiable, Equatable {
  var id = UUID()
  
  @Published var isInit: Bool = false
  
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
  
  var webviewIsError: Bool = false
  var webviewCheckError: Bool = false
  var webviewErrorType: WebViewErrorType = .noError
  
  @Published var title: String = ""
  @Published var favicon: Image? = nil
  var faviconData: Data? = nil
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  @Published var historySiteDataList: [HistorySite] = []
  @Published var historyBackList: [WKBackForwardListItem] = []
  @Published var historyForwardList: [WKBackForwardListItem] = []
  
  @Published var isPageProgress: Bool = false
  @Published var pageProgress: Double = 0.0
  
  @Published var isEditSearch: Bool = false
  
  @Published var isLocationDialogIcon: Bool = false
  @Published var isNotificationDialogIcon: Bool = false
  
  @Published var isNotificationPermissionByApp: Bool = false
  @Published var isNotificationPermission: Bool = false
  
  lazy var webview: WKWebView = {
    let config = WKWebViewConfiguration()
    
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    config.defaultWebpagePreferences = prefs
    
    config.setURLSchemeHandler(SchemeHandler(), forURLScheme: "opacity")
    
    let contentController = WKUserContentController()
    let scriptHandler = ScriptHandler(tab: self)
    AppDelegate.shared.locationManager.delegate = scriptHandler
    contentController.add(scriptHandler, name: "opacityBrowser")
    
    config.userContentController = contentController
    
    let scriptSource = """
      // geolocation
      window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "initGeoPositions" });
    
      // notification
      const originalNotification = Notification;
      class OpacityNotification {
        static requestPermission = () => window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "notificationRequest" });
        constructor(title, options) {
          window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showNotification", value: JSON.stringify({ title: title, options: options })});
          return new originalNotification(title, options);
        }
      };
      Object.defineProperty(OpacityNotification, 'permission', {
        get: () => originalNotification.permission
      });
      window.Notification = OpacityNotification;
    """
    let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    config.userContentController.addUserScript(userScript)
    
    let preferences = WKPreferences()
    preferences.setValue(true, forKey: "developerExtrasEnabled")
    config.preferences = preferences
    
    let webView = WKWebView(frame: .zero, configuration: config)
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
      if enabled {
        self.isNotificationPermissionByApp = true
        let host: String = url.host!
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
  
  func clearPermission() {
    DispatchQueue.main.async {
      self.isLocationDialogIcon = false
      self.isNotificationDialogIcon = false
    }
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
      self.clearPermission()
      self.setDomainPermission(url)
    }
  }
  
  func updateURLByBrowser(url: URL) {
    DispatchQueue.main.async {
      self.isInit = false
      self.originURL = url
      self.inputURL = StringURL.setInputURL(url)
      self.printURL = StringURL.setPrintURL(url)
      self.title = StringURL.setTitleURL(url)
      self.favicon = nil
      self.clearPermission()
      self.setDomainPermission(url)
    }
  }
  
  func loadFavicon(url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, let uiImage = NSImage(data: data) else {
        return
      }
      DispatchQueue.main.async {
        self.faviconData = data
        withAnimation {
          self.favicon = Image(nsImage: uiImage)
        }
      }
    }.resume()
  }
  
  static func == (lhs: Tab, rhs: Tab) -> Bool {
    return lhs.id == rhs.id
  }
}
