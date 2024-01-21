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
  @Published var favicon: URL?
  
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
}
