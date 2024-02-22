//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
  @ObservedObject var browser: Browser
  @State private var snapshotIndex: Double = 0

  var body: some View {
    VStack(spacing: 0) {
      // webview area
      ZStack {
        if browser.tabs.count > 0 {
          if let snapshot = browser.snapshot {
            Image(nsImage: snapshot)
              .zIndex(snapshotIndex)
          }
          ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
            if let activeId = browser.activeTabId, activeId == tab.id {
              WebNSView(browser: browser, tab: browser.tabs[index])
                .zIndex(1)
            }
          }
        }
      }
      .background(.red)
      .onChange(of: browser.snapshot) { oldValue, newValue in
        if oldValue == nil && newValue != nil {
          DispatchQueue.main.async {
            snapshotIndex = 3
          }
        } else {
          snapshotIndex = 0
        }
      }
    }
  }
}
