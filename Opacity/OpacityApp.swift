//
//  OpacityApp.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

@main
struct OpacityApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
      Settings {
        
      }
    }
//    WindowGroup {
//      ContentView()
//        .environmentObject(Browser())
//    }
//    .windowStyle(HiddenTitleBarWindowStyle())
  
//  @State var tabs: [Tab] = []
//  @State var activeTabIndex: Int = -1
//  
//  var body: some Scene {
//    WindowGroup {
//      ContentView(tabs: $tabs, activeTabIndex: $activeTabIndex)
//        .onAppear {
//          NSWindow.allowsAutomaticWindowTabbing = false
//        }
//    }
//    .windowStyle(HiddenTitleBarWindowStyle())
//    .commands {
//      CommandGroup(replacing: .appVisibility) { }
//      CommandGroup(replacing: .importExport) { }
//      CommandGroup(replacing: .newItem) { }
//      CommandGroup(replacing: .pasteboard) { }
//      CommandGroup(replacing: .printItem) { }
//      CommandGroup(replacing: .saveItem) { }
//      CommandGroup(replacing: .singleWindowList) { }
//      CommandGroup(replacing: .systemServices) { }
//      CommandGroup(replacing: .undoRedo) { }
//      CommandGroup(after: .newItem) {
//        Button("New Tab") {
//          let newTab = Tab(webURL: DEFAULT_URL)
//          tabs.append(newTab)
//          activeTabIndex = tabs.count - 1
//        }
//        .keyboardShortcut(KeyEquivalent("t"), modifiers: .command)
//        Button("New Window") {
//          
//        }
//        .keyboardShortcut(KeyEquivalent("n"), modifiers: .command)
//        Divider()
//        Button("Close Tab") {
//          tabs.remove(at: activeTabIndex)
//          activeTabIndex = activeTabIndex > 0 ? activeTabIndex - 1 : tabs.count - 1
//        }
//        .keyboardShortcut(KeyEquivalent("w"), modifiers: .command)
//      }
//    }
//  }
}
