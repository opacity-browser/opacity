//
//  Browser.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

final class Browser: ObservableObject, Identifiable {
  var id: UUID
  var windowNumber: Int
  @Published var tabs: [Tab] = []
  @Published var activeTabId: UUID?
  @Published var isSideBar: Bool = false
  @Published var searchBoxRect: CGRect?
  
  init(service: Service, windowNumber: Int, tabId: UUID? = nil) {
    self.id = UUID()
    self.windowNumber = windowNumber
    if let tabId = tabId {
      self.moveNewBrowserTab(service: service, tabId: tabId)
    } else {
      self.initTab()
    }
  }
  
  func initTab() {
    let newTab = Tab(url: INIT_URL)
    newTab.isInit = true
    newTab.isInitFocus = true
    newTab.inputURL = ""
    newTab.printURL = ""
    newTab.title = NSLocalizedString("New Tab", comment: "")
    DispatchQueue.main.async {
      self.tabs.append(newTab)
      self.activeTabId = newTab.id
    }
  }
  
  func moveNewBrowserTab(service: Service, tabId: UUID) {
    for (_, targetBrowser) in service.browsers {
      if let targetTabIndex = targetBrowser.tabs.firstIndex(where: { $0.id == tabId }) {
        let targetTab = targetBrowser.tabs[targetTabIndex]
        tabs.append(targetTab)
        activeTabId = targetTab.id
        
        targetBrowser.tabs.remove(at: targetTabIndex)
        if targetBrowser.tabs.count > 0 {
          let newTargetTabIndex = targetTabIndex == 0 ? 0 : targetTabIndex - 1
          targetBrowser.activeTabId = targetBrowser.tabs[newTargetTabIndex].id
        }
        break
      }
    }
  }
  
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
  
  func closeAllTab(completion: @escaping () -> Void) {
    let group = DispatchGroup()
    for tab in tabs {
      print("close tab: \(tab.title)")
      group.enter()
      tab.closeTab {
        print("\(tab.title) closed.")
        group.leave()
      }
    }
    group.notify(queue: .main) {
      print("closed all tab.")
      completion()
    }
  }
}
