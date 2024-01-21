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
  
  @Published var originURL: String {
    didSet {
      objectWillChange.send()
    }
  }
  @Published var printURL: String
  @Published var inputURL: String
  
  @Published var title: String = "New Tab"
  @Published var favicon: Image = Image("icon-16")
  
  @Published var isBack: Bool = false
  @Published var isForward: Bool = false
  
  var webview: WKWebView?
  
  init(url: String = DEFAULT_URL) {
    self.originURL = url
    self.inputURL = url
    self.printURL = StringURL.shortURL(url: url)
  }
  
  func updateURL(url: String) {
    self.originURL = url
    self.inputURL = url
    self.printURL = StringURL.shortURL(url: url)
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
      self.favicon = Image("icon-16")
    }
  }
}
