//
//  CustomTitlebarView.swift
//  Opacity
//
//  Created by Falsy on 10/11/24.
//

import SwiftUI

struct TitlebarTabView: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @State var isFullScreen: Bool = false
  
  var body: some View {
    HStack {
      if isFullScreen {
        EmptyView()
      } else {
        TitlebarTabProvider(service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId, isFullScreen: $isFullScreen)
      }
    }
    .onAppear {
      isFullScreen = AppDelegate.shared.isFullScreenMode
    }
    .onChange(of: AppDelegate.shared.isFullScreenMode) { _, nV in
      isFullScreen = nV
    }
  }
}
