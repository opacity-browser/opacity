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
  
  func clearSearchEditMode() {
    for index in tabs.indices {
      tabs[index].isEditSearch = false
      tabs[index].autoCompleteList = []
      tabs[index].autoCompleteIndex = nil
      tabs[index].autoCompleteText = ""
    }
  }
  
  func updateActiveTab(tabId: UUID, webView: WKWebView) {
    DispatchQueue.main.async {
      self.clearSearchEditMode()
      self.activeTabId = tabId
    }
  }
  
  func newTab(_ url: URL = DEFAULT_URL) {
    let newTab = Tab(url: url)
    DispatchQueue.main.async {
      self.clearSearchEditMode()
      self.tabs.append(newTab)
      self.activeTabId = newTab.id
    }
  }
  
  func initTab() {
    let newTab = Tab(url: INIT_URL)
    newTab.isInit = true
    newTab.inputURL = ""
    newTab.printURL = ""
    newTab.title = NSLocalizedString("New Tab", comment: "")
    DispatchQueue.main.async {
      self.tabs.append(newTab)
      self.activeTabId = newTab.id
    }
  }
}
