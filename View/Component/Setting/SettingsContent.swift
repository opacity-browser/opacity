//
//  SettingsContent.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct SettingsContent: View {
  let selectedCategory: SettingsCategory
  let generalSettings: [GeneralSetting]
  @ObservedObject var browser: Browser
  
  init(selectedCategory: SettingsCategory, generalSettings: [GeneralSetting], browser: Browser) {
    self.selectedCategory = selectedCategory
    self.generalSettings = generalSettings
    self.browser = browser
  }
  
  var body: some View {
      ScrollView {
      VStack(spacing: 0) {
        switch selectedCategory {
        case .general:
          GeneralSettingsView(browser: browser, generalSettings: generalSettings)
        case .searchHistory:
          SearchHistorySettingsView()
        case .visitHistory:
          VisitHistorySettingsView()
        case .permissions:
          PermissionsSettingsView(browser: browser)
        case .library:
          LibrarySettingsView(browser: browser)
        }
      }
      .padding(.horizontal, 40)
      .padding(.top, 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
