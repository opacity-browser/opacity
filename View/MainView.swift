//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
  @ObservedObject var browser: Browser
  @Query(filter: #Predicate<BookmarkGroup> {
    $0.parentGroupId == nil
  }) var bookmarkGroups: [BookmarkGroup]

  var body: some View {
    HStack(spacing: 0) {
      GeometryReader { geometry in
        ZStack {
          if browser.tabs.count > 0 {
            ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
              if let activeId = browser.activeTabId {
                WebNSView(browser: browser, tab: browser.tabs[index])
                  .offset(y: tab.id == activeId ? 0 : geometry.size.height + 1)
                  .frame(height: geometry.size.height + 1)
              }
            }
          }
        }
      }
      if browser.isSideBar {
        SideBarView(browser: browser, bookmarkGroups: bookmarkGroups)
      }
    }
  }
}
