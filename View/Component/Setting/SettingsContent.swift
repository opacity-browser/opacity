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
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        switch selectedCategory {
        case .general:
          GeneralSettingsView(generalSettings: generalSettings)
        case .searchHistory:
          SearchHistorySettingsView()
        case .visitHistory:
          VisitHistorySettingsView()
        case .permissions:
          PermissionsSettingsView()
        case .library:
          LibrarySettingsView()
        }
      }
      .padding(.horizontal, 40)
      .padding(.top, 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
