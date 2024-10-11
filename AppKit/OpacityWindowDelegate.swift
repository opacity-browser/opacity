//
//  OpacityWindowDelegate.swift
//  Opacity
//
//  Created by Falsy on 10/11/24.
//

import SwiftUI

class OpacityWindowDelegate: NSObject, NSWindowDelegate, ObservableObject {
  var windowMap: [UUID:NSWindow] = [:]
  @Published var isFullScreen: Bool = false
  var lastActivationTime: Date?
  
  func windowWillEnterFullScreen(_ notification: Notification) {
    AppDelegate.shared.isFullScreenMode = true
    DispatchQueue.main.async {
      self.isFullScreen = true
    }
    if let keyWindow = NSApplication.shared.keyWindow {
      keyWindow.toolbar = nil
    }
  }
  
  func windowDidEnterFullScreen(_ notification: Notification) {
  }
  
  func windowWillExitFullScreen(_ notification: Notification) {
    AppDelegate.shared.isFullScreenMode = false
    DispatchQueue.main.async {
      self.isFullScreen = false
      if let keyWindow = NSApplication.shared.keyWindow {
        keyWindow.toolbar = NSToolbar()
      }
    }
  }

  func windowDidExitFullScreen(_ notification: Notification) {
  }
  
  func windowDidBecomeMain(_ notification: Notification) {
    print("windowDidBecomeMain")
    let currentTime = Date()
    if let lastTime = lastActivationTime {
      let elapsedTime = currentTime.timeIntervalSince(lastTime)
      if elapsedTime >= 3600 {
        AppDelegate.shared.deleteExpiredData()
        lastActivationTime = currentTime
      }
    } else {
      AppDelegate.shared.deleteExpiredData()
      lastActivationTime = currentTime
    }
  }
  
  func windowWillClose(_ notification: Notification) {
    print("windowWillClose")
    guard let window = notification.object as? NSWindow else { return }
    let frameString = NSStringFromRect(window.frame)
    UserDefaults.standard.set(frameString, forKey: "lastWindowFrame")
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    print("windowShouldClose")
    let windowNumber = sender.windowNumber
    if let browser = AppDelegate.shared.service.browsers[windowNumber] {
      let tabs = browser.tabs
      for tab in tabs {
        AppDelegate.shared.closeInspector(tab.id)
      }
      browser.closeAllTab {
        browser.tabs = []
        AppDelegate.shared.service.browsers[windowNumber] = nil
        sender.close()
      }
      return false
    } else {
      return true
    }
  }
}
