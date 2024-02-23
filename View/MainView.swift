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
      GeometryReader { geometry in
        ZStack {
          if browser.tabs.count > 0 {
            ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
              if let activeId = browser.activeTabId {
                WebNSView(browser: browser, tab: browser.tabs[index])
                  .offset(y: tab.id == activeId ? 0 : geometry.size.height)
              }
            }
          }
        }
      }
    }
  }
}
