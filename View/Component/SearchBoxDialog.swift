//
//  SearchBoxDialog.swift
//  Opacity
//
//  Created by Falsy on 3/16/24.
//

import SwiftUI
import SwiftData

struct SearchBoxDialog: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @Binding var activeTabId: UUID?
  @Binding var isFullScreen: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
        SearchEditBox(service: service, browser: browser, tab: activeTab)
          .padding(.top, isFullScreen ? 38 : 0)
      }
    }
  }
}
