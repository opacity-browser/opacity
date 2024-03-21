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
  @Binding var autoCompleteList: [SearchHistoryGroup]
  @Binding var autoCompleteIndex: Int?
  
  var body: some View {
    VStack(spacing: 0) {
      if autoCompleteList.count > 0 {
        ForEach(Array(autoCompleteList.enumerated()), id: \.element.id) { index, autoComplete in
          SearchAutoCompleteItem(browser: browser, tab: tab, searchHistoryGroup: autoComplete, isActive: autoCompleteIndex == index)
        }
      }
    }
    .padding(.bottom, 5)
  }
}
