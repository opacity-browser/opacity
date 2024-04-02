//
//  Settings.swift
//  Opacity
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI
import SwiftData


enum SearchEngineList: String {
  case google = "Google"
  case bing = "Bing"
  case yahoo = "Yahoo"
  case duckduckgo = "DuckDuckGo"
}

enum ScreenModeList: String {
  case system = "System"
  case light = "Light"
  case dark = "Dark"
}

enum DataRententionPeriodList: String {
  case oneWeek = "1 Week"
  case oneMonth = "1 Month"
  case indefinite = "Indefinite"
}

@Model
class OpacityBrowserSettings {
  var searchEngine: String
  var screenMode: String
  var retentionPeriod = "1 Week"
  
  init(searchEngine: String = SearchEngineList.google.rawValue, screenMode: String = ScreenModeList.system.rawValue, retentionPeriod: String = DataRententionPeriodList.oneWeek.rawValue) {
    self.searchEngine = searchEngine
    self.screenMode = screenMode
    self.retentionPeriod = retentionPeriod
  }
}
