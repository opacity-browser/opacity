//
//  OpacityWebView.swift
//  Opacity
//
//  Created by Falsy on 4/17/24.
//

import SwiftUI
import WebKit

enum ContextualMenuAction {
  case downloadImage
}

class OpacityWebView: WKWebView {
  var contextualMenuAction: ContextualMenuAction?
  var openImageNewWindowMenuItem: NSMenuItem?
  
  override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
    super.willOpenMenu(menu, with: event)
    
    if let openNewWindowImage = menu.items.first(where: { $0.identifier?.rawValue ?? "" == "WKMenuItemIdentifierOpenImageInNewWindow" }) {
      self.openImageNewWindowMenuItem = openNewWindowImage
    }
    
    for menuItem in menu.items {
      if menuItem.identifier?.rawValue ?? "" == "WKMenuItemIdentifierDownloadImage" {
        menuItem.title = NSLocalizedString("Save Image As..", comment: "")
        menuItem.action = #selector(self.menuClick(_:))
        menuItem.target = self
      }
      
      if menuItem.identifier?.rawValue ?? "" == "WKMenuItemIdentifierDownloadLinkedFile" {
        menuItem.isHidden = true
      }
    }
  }
  
  override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
    super.didCloseMenu(menu, with: event)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.contextualMenuAction = nil
      self.openImageNewWindowMenuItem = nil
    }
  }
  
  @objc func menuClick(_ menuItem: NSMenuItem) {
    self.contextualMenuAction = .downloadImage
    if let openImageNewWindowMenuItem = self.openImageNewWindowMenuItem, let action = openImageNewWindowMenuItem.action {
      NSApp.sendAction(action, to: openImageNewWindowMenuItem.target, from: openImageNewWindowMenuItem)
    }
  }
}
