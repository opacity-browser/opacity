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
  @State private var isSidebarOpen: Bool = false
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
    .commands {
      MainCommands(appDelegate: appDelegate)
    }
  }
}
