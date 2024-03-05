//
//  NavigationView.swift
//  Opacity
//
//  Created by Falsy on 3/5/24.
//

import SwiftUI

struct NavigationView: View {
  @ObservedObject var browser: Browser
  @Binding var activeTabId: UUID?
  @Binding var isFullScreen: Bool

  var body: some View {
    VStack(spacing: 0) {
      if !isFullScreen {
        Rectangle()
          .frame(height: 1)
          .foregroundColor(Color("UIBorder"))
      }
      Rectangle()
        .frame(height: 3.5)
        .foregroundColor(Color("SearchBarBG"))
      if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
        Navigation(tab: activeTab)
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
