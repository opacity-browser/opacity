//
//  NavigationView.swift
//  Opacity
//
//  Created by Falsy on 3/5/24.
//

import SwiftUI

struct NavigationSearchView: View {
  @ObservedObject var browser: Browser
  @Binding var activeTabId: UUID?
  @Binding var isFullScreen: Bool
  @ObservedObject var manualUpdate: ManualUpdate

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .frame(height: 3.5)
        .foregroundColor(Color("SearchBarBG"))
      if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
        Navigation(browser: browser, tab: activeTab, manualUpdate: manualUpdate)
          .frame(maxWidth: .infinity,  maxHeight: 41)
          .background(Color("SearchBarBG"))
          .background(.blue)
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
