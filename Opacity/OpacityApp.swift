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
      EmptyView()
    }
    .commands {
      MainCommands(appDelegate: appDelegate)
      CleanCommands(appDelegate: appDelegate)
    }
  }
}
