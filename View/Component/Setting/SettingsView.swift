//
//  SettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
  @Query var generalSettings: [GeneralSetting]
  @State private var selectedCategory: SettingsCategory = .general
  @ObservedObject var browser: Browser
  
  init(browser: Browser) {
    self.browser = browser
  }
  
  var body: some View {
    HStack(spacing: 0) {
      SettingsSidebar(selectedCategory: $selectedCategory)
      
      VStack(spacing: 0) {
        Rectangle()
          .frame(width: 0.5)
          .foregroundColor(Color("UIBorder"))
      }
      
      SettingsContent(selectedCategory: selectedCategory, generalSettings: generalSettings, browser: browser)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color("SearchBarBG"))
  }
}

enum SettingsCategory: String, CaseIterable {
  case general = "General"
  case searchHistory = "Search History"
  case visitHistory = "Visit History"
  case permissions = "Permissions"
  case library = "Library"
  
  var localizedTitle: String {
    NSLocalizedString(self.rawValue, comment: "")
  }
  
  var icon: String {
    switch self {
    case .general:
      return "gearshape"
    case .searchHistory:
      return "magnifyingglass.circle"
    case .visitHistory:
      return "clock"
    case .permissions:
      return "shield"
    case .library:
      return "books.vertical"
    }
  }
}
