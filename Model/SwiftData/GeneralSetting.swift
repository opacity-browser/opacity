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
  case oneDay = "1 Day"
  case oneWeek = "1 Week"
  case oneMonth = "1 Month"
  case indefinite = "Indefinite"
}

// Deprecated
enum BlockingTrakerList: String {
  case blockingStrong = "blocking-strong"
  case blockingModerate = "blocking-moderate"
  case blockingLight = "blocking-light"
  case blockingNone = "blocking-none"
}

@Model
class GeneralSetting {
  var searchEngine: String
  var screenMode: String
  var retentionPeriod: String
  var blockingLevel: String // Deprecated
  var adBlocking: Bool = true // Deprecated
  var isTrackerBlocking: Bool = true
  
  init(searchEngine: String = SearchEngineList.google.rawValue, screenMode: String = ScreenModeList.system.rawValue, retentionPeriod: String = DataRententionPeriodList.oneWeek.rawValue, blockingLevel: String = BlockingTrakerList.blockingModerate.rawValue, adBlocking: Bool = true, isTrackerBlocking: Bool = true) {
    self.searchEngine = searchEngine
    self.screenMode = screenMode
    self.retentionPeriod = retentionPeriod
    self.blockingLevel = blockingLevel
    self.adBlocking = adBlocking
    self.isTrackerBlocking = isTrackerBlocking
  }
}
