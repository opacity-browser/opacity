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
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
  
  @Published var title: String = ""
  @Published var favicon: Image?
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  @Published var pageProgress: Double = 0.0
  @Published var test: Bool = false
  
//  var printWebview: Webview?
  lazy var webview: WKWebView = {
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
  
  func updateURLBySearch(url: URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    DispatchQueue.main.async {
      self.isUpdateBySearch = true
      self.originURL = url
      self.inputURL = stringURL
      self.printURL = shortStringURL
      self.title = shortStringURL
      self.favicon = nil
    }
  }
  
  func updateURLByBrowser(url: URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    DispatchQueue.main.async {
      self.originURL = url
      self.inputURL = stringURL
      self.printURL = shortStringURL
      self.title = shortStringURL
      self.favicon = nil
    }
  }
  
  func loadFavicon(url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, let uiImage = NSImage(data: data) else {
        self.setDefaultFavicon()
        return
      }
      DispatchQueue.main.async {
        withAnimation {
          self.favicon = Image(nsImage: uiImage)
        }
      }
    }.resume()
  }
  
  func setDefaultFavicon() {
    DispatchQueue.main.async {
      withAnimation {
        self.favicon = nil
      }
    }
  }
  
  static func == (lhs: Tab, rhs: Tab) -> Bool {
    return lhs.id == rhs.id
  }
}
