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

  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  var body: some View {
    VStack(spacing: 0) {
      if let searchBoxRect = browser.searchBoxRect {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            HStack(spacing: 0) {
              VStack(spacing: 0) {
                SearchAutoCompleteBox(service: service, browser: browser, tab: tab, tabWidth: CGFloat(searchBoxRect.width) + 4)
              }
              .frame(width: searchBoxRect.width + 4)
            }
            .background(Color(tab.isEditSearch ? "ActiveInputBG" : "InputBG"))
            .clipShape(RoundedRectangle(cornerRadius: tab.isEditSearch ? 18 : 15))
            .shadow(color: .black.opacity(tab.isEditSearch ? colorScheme == .dark ? 0.4 : 0.15 : 0), radius: 4, x: 0, y: 2)
            Spacer()
          }
          Spacer()
        }
        .padding(.top, tab.isEditSearch ? 4.5 : 6.5)
        .padding(.leading, 125)
      }
    }
  }
}
