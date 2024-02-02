//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI
import WebKit

//enum WebviewError {
//  case noError
//  case notFind
//  case notHttps
//  case notNetwork
//  case notConnect
//}

final class Tab: ObservableObject, Identifiable, Equatable {

  static func == (lhs: Tab, rhs: Tab) -> Bool {
    return lhs.id == rhs.id
  }
  
  var id = UUID()
  @Published var originURL: URL
  @Published var printURL: String
  @Published var inputURL: String
  
  var isUpdateBySearch: Bool = false
//  var prevURL: URL
  
  @Published var title: String = ""
  @Published var favicon: Image?
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
//  @Published var isErrorStatus: WebviewError = .noError
  
  var webview: WKWebView?
  
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
}
