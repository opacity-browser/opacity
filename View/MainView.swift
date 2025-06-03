//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  
  var body: some View {
    HStack(spacing: 0) {
      GeometryReader { geometry in
        ZStack {
          if browser.tabs.count > 0 {
            ForEach(Array(browser.tabs.enumerated()), id: \.element.id) { index, tab in
              if let activeId = browser.activeTabId {
                TabContentView(
                  service: service,
                  browser: browser,
                  tab: tab,
                  isActive: tab.id == activeId,
                  geometryHeight: geometry.size.height
                ).onTapGesture {
                  // 활성 탭의 검색 상태를 해제
                  if let activeTab = browser.tabs.first(where: { $0.id == activeId }) {
                    DispatchQueue.main.async {
                      activeTab.isEditSearch = false
                    }
                  }
                }
              }
            }
          }
        }
      }
      if browser.isSideBar {
        SideBarView(service: service, browser: browser)
      }
    }
  }
}
