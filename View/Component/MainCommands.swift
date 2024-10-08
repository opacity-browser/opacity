//
//  Commands.swift
//  Opacity
//
//  Created by Falsy on 10/9/24.
//

import SwiftUI

struct MainCommands: Commands {
    @ObservedObject var appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    var body: some Commands {
      CommandGroup(replacing: .appInfo) {
        Button(NSLocalizedString("About Opacity", comment: "")) {
          AppDelegate.shared.openAboutWindow()
        }
      }
      
      CommandGroup(replacing: .newItem) {
        Button(NSLocalizedString("New Window", comment: "")) {
          AppDelegate.shared.newWindow()
        }
        .keyboardShortcut("n", modifiers: .command)
      }
      
      CommandGroup(after: .appInfo) {
        Divider()
        Button(NSLocalizedString("Settings", comment: "")) {
          AppDelegate.shared.openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)
      }
      
      CommandGroup(after: .newItem) {
        Button(NSLocalizedString("New Tab", comment: "")) {
          AppDelegate.shared.newTab()
        }
        .keyboardShortcut("t", modifiers: .command)
        Divider()
        Button(NSLocalizedString("Close Window", comment: "")) {
          AppDelegate.shared.closeWindow()
        }
        .keyboardShortcut("w", modifiers: [.command, .shift])
        Button(NSLocalizedString("Close Tab", comment: "")) {
          AppDelegate.shared.closeTab()
        }
        .keyboardShortcut("w", modifiers: .command)
      }
      
      CommandGroup(after: .pasteboard) {
        Divider()
        Button(NSLocalizedString("Find in Page...", comment: "")) {
          AppDelegate.shared.findKeyword()
        }
        .keyboardShortcut("f", modifiers: .command)
        Button(NSLocalizedString("Find Next", comment: "")) {
          AppDelegate.shared.findKeywordNext()
        }
        .keyboardShortcut("g", modifiers: .command)
        Button(NSLocalizedString("Find Previous", comment: "")) {
          AppDelegate.shared.findKeywordPrev()
        }
        .keyboardShortcut("g", modifiers: [.command, .shift])
      }
      
      CommandGroup(replacing: .sidebar) {
        Divider()
        if appDelegate.isOpenSidebar {
          Button(NSLocalizedString("Hide Sidebar", comment: "")) {
            AppDelegate.shared.isSidebar()
          }
          .keyboardShortcut("s", modifiers: .command)
        } else {
          Button(NSLocalizedString("Show Sidebar", comment: "")) {
            AppDelegate.shared.isSidebar()
          }
          .keyboardShortcut("s", modifiers: .command)
        }
      }
      
      CommandGroup(before: .sidebar) {
        Button(NSLocalizedString("Reload Page", comment: "")) {
          AppDelegate.shared.refreshTab()
        }
        .keyboardShortcut("r", modifiers: .command)
        Button(NSLocalizedString("Refresh after clearing cache", comment: "")) {
          AppDelegate.shared.refreshTabAfterClearingCache()
        }
        .keyboardShortcut("r", modifiers: [.command, .shift])
      }
      
      CommandGroup(after: .sidebar) {
        Divider()
        Button(NSLocalizedString("Zoom In", comment: "")) {
          AppDelegate.shared.zoomIn()
        }
        .keyboardShortcut("+", modifiers: .command)
        Button(NSLocalizedString("Zoom Out", comment: "")) {
          AppDelegate.shared.zoomOut()
        }
        .keyboardShortcut("-", modifiers: .command)
        Divider()
      }
      
      CommandGroup(replacing: .saveItem) {
        
      }
    }
}
