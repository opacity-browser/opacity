//
//  NavigationView.swift
//  Opacity
//
//  Created by Falsy on 3/5/24.
//

import SwiftUI

struct NavigationSearchView: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @Binding var activeTabId: UUID?
  @Binding var isFullScreen: Bool

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .frame(height: 3.5)
        .foregroundColor(Color("SearchBarBG"))
      if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
        Navigation(service: service, browser: browser, tab: activeTab)
          .id(activeTab.id)
          .frame(maxWidth: .infinity,  maxHeight: 41)
          .background(Color("SearchBarBG"))
        Rectangle()
          .frame(height: 0.5)
          .foregroundColor(Color("SearchBarBG"))
        Rectangle()
          .frame(height: 0.5)
          .foregroundColor(Color("UIBorder"))
      }
    }
  }
}
