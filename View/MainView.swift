//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
//  @Environment(\.colorScheme) var colorScheme
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  
  var body: some View {
    VStack(spacing: 0) {
      // webview area
      ZStack {
        if tabs.count > 0 {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, item in
            Webview(tabs: $tabs, activeTabIndex: $activeTabIndex, tab: tabs[index]).zIndex(index == activeTabIndex ? Double(tabs.count) : 0)
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
