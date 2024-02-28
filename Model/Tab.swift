//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI
import WebKit

final class Tab: ObservableObject, Identifiable, Equatable {
  var id = UUID()
  
  @Published var isInit: Bool = false
  
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
  
  @Published var title: String = ""
  @Published var favicon: Image? = nil
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  @Published var historySiteDataList: [HistorySite] = []
  @Published var historyBackList: [WKBackForwardListItem] = []
  @Published var historyForwardList: [WKBackForwardListItem] = []
  
  @Published var isPageProgress: Bool = false
  @Published var pageProgress: Double = 0.0
  
  @Published var isEditSearch: Bool = true
  
  @Published var isLocationDialog: Bool = false
  @Published var isNotificationDialog: Bool = false
  
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
      window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "initGeoPositions" });
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
    
    return WKWebView(frame: .zero, configuration: config)
  }()
  
  init(url: URL = DEFAULT_URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    self.originURL = url
    self.inputURL = stringURL
    self.printURL = shortStringURL
    self.title = shortStringURL
  }
  
  func clearPermission() {
    DispatchQueue.main.async {
      self.isLocationDialog = false
      self.isNotificationDialog = false
    }
  }
  
  func updateURLBySearch(url: URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    DispatchQueue.main.async {
      self.isInit = false
      self.isUpdateBySearch = true
      self.originURL = url
      self.inputURL = stringURL
      self.printURL = shortStringURL
      self.title = shortStringURL
      self.favicon = nil
      self.clearPermission()
    }
  }
  
  func updateURLByBrowser(url: URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    DispatchQueue.main.async {
      self.isInit = false
      self.originURL = url
      self.inputURL = stringURL
      self.printURL = shortStringURL
      self.title = shortStringURL
      self.favicon = nil
      self.clearPermission()
    }
  }
  
  func loadFavicon(url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, let uiImage = NSImage(data: data) else {
        return
      }
      DispatchQueue.main.async {
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
