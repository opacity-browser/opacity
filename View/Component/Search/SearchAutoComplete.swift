//
//  SearchAutoComplete.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchAutoComplete: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  var body: some View {
    VStack(spacing: 0) {
      if tab.autoCompleteList.count > 0 {
        ForEach(Array(tab.autoCompleteList.enumerated().prefix(5)), id: \.element.id) { index, autoComplete in
          SearchAutoCompleteItemNSView(browser: browser, tab: tab, searchHistoryGroup: autoComplete, isActive: tab.autoCompleteIndex == index)
            .allowsHitTesting(true)
        }
      }
      if tab.autoCompleteVisitList.count > 0 {
        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 1)
          .foregroundColor(Color("UIBorder"))
          .padding(.vertical, 4)
          .opacity(0.5)
        ForEach(Array(tab.autoCompleteVisitList.enumerated().prefix(5)), id: \.element.id) { index, autoComplete in
          SearchAutoCompleteVisitItemNSView(browser: browser, tab: tab, visitHistoryGroup: autoComplete, isActive: tab.autoCompleteIndex == tab.autoCompleteList.count + index)
            .allowsHitTesting(true)
        }
      }
    }.padding(.bottom, 5)
  }
}
