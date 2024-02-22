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
  @Published var snapshot: NSImage?
  
  private var currentWorkItem: DispatchWorkItem?
  
  func updateActiveTab(tabId: UUID, webView: WKWebView) {
    currentWorkItem?.cancel()
    takeSnapshot(webView: webView)
    
    let workItem = DispatchWorkItem { [weak self] in
      self?.activeTabId = tabId
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self?.snapshot = nil
      }
    }
    
    currentWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: workItem)
  }
  
  func takeSnapshot(webView: WKWebView) {
    let configuration = WKSnapshotConfiguration()

    webView.takeSnapshot(with: configuration) { image, error in
      guard let image = image, error == nil else {
        print("err")
        self.snapshot = nil
        return
      }
      print("snapshot")
      self.snapshot = image
    }
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
    self.tabs.append(newTab)
    self.activeTabId = newTab.id
  }
}
