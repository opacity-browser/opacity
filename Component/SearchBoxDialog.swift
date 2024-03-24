//
//  SearchBoxDialog.swift
//  Opacity
//
//  Created by Falsy on 3/16/24.
//

import SwiftUI
import SwiftData

struct SearchBoxDialog: View {
  @ObservedObject var browser: Browser
  @Binding var activeTabId: UUID?
  @ObservedObject var manualUpdate: ManualUpdate
  
  var body: some View {
    VStack(spacing: 0) {
      if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
        SearchEditBox(browser: browser, tab: activeTab, manualUpdate: manualUpdate)
      }
    }
  }
}
