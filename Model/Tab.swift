//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI
import WebKit

final class Tab: ObservableObject, Identifiable {
  var id = UUID()
  
  @Published var originURL: URL {
    didSet {
      objectWillChange.send()
    }
  }
  @Published var printURL: String
  @Published var inputURL: String
  
  @Published var title: String = ""
  @Published var favicon: Image = Image("egg")
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  var webview: WKWebView?
  
  init(url: URL = DEFAULT_URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    self.originURL = url
    self.inputURL = stringURL
    self.printURL = shortStringURL
    self.title = shortStringURL
  }
  
  func updateURL(url: URL) {
    let stringURL = String(describing: url)
    let shortStringURL = StringURL.shortURL(url: stringURL)
    
    self.originURL = url
    self.inputURL = stringURL
    self.printURL = shortStringURL
    self.title = shortStringURL
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
  
  func setDefaultFavicon() {
    withAnimation {
      self.favicon = Image("egg")
    }
  }
}
