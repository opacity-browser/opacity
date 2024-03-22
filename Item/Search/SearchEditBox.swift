//
//  SearchEditBox.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchEditBox: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.modelContext) var modelContext
  @Query(sort: \SearchHistoryGroup.updateDate, order: .reverse)
  var searchHistoryGroups: [SearchHistoryGroup]
  @Query var searchHistories: [SearchHistory]

  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @ObservedObject var manualUpdate: ManualUpdate
  
  var body: some View {
    VStack(spacing: 0) {
      if let searchBoxRect = browser.searchBoxRect {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            HStack(spacing: 0) {
              VStack(spacing: 0) {
                SearchAutoCompleteBox(browser: browser, tab: tab, manualUpdate: manualUpdate, searchHistoryGroups: searchHistoryGroups)
              }
              .frame(width: searchBoxRect.width + 4)
            }
            .background(Color(tab.isEditSearch ? "ActiveInputBG" : "InputBG"))
            .clipShape(RoundedRectangle(cornerRadius: tab.isEditSearch ? 18 : 15))
            .shadow(color: .black.opacity(tab.isEditSearch ? colorScheme == .dark ? 0.3 : 0.15 : 0), radius: 4, x: 0, y: 3)
            Spacer()
          }
          Spacer()
        }
        .padding(.top, tab.isEditSearch ? 5 : 7.5)
        .padding(.leading, searchBoxRect.minX - 2)
      }
    }
  }
}
