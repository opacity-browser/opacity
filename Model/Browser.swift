//
//  Browser.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

final class Browser: ObservableObject, Identifiable {
  var id = UUID()
  var windowNumber: Int?
  @Published var tabs: [Tab] = []
  @Published var activeTabId: UUID?
  @Published var isSideBar: Bool = false
  @Published var searchBoxRect: CGRect?
  
  private var currentWorkItem: DispatchWorkItem?
  
  func updateActiveTab(tabId: UUID, webView: WKWebView) {
    self.activeTabId = tabId
  }
  
  func newTab(_ url: URL = DEFAULT_URL) {
    let newTab = Tab(url: url)
    self.tabs.append(newTab)
    self.activeTabId = newTab.id
  }
  
  func initTab() {
    let newTab = Tab(url: INIT_URL)
    newTab.isInit = true
    newTab.inputURL = ""
    newTab.printURL = ""
    newTab.title = "\(NSLocalizedString("New Tab", comment: ""))"
    newTab.isEditSearch = true
    self.tabs.append(newTab)
    self.activeTabId = newTab.id
  }
}
