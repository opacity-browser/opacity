//
//  GeneralSettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//


import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
  @Environment(\.modelContext) var modelContext
  @ObservedObject var browser: Browser
  let generalSettings: [GeneralSetting]
  
  init(browser: Browser, generalSettings: [GeneralSetting]) {
    self.browser = browser
    self.generalSettings = generalSettings
  }
  
  @State private var selectedLanguage: String = "Korean"
  @State private var selectedScreenMode: String = "System"
  @State private var selectedSearchEngine: String = "Google"
  @State private var selectedRetentionPeriod: String = "1 Week"
  @State private var isTrackerBlocking: Bool = true
  
  private let languages = ["Korean", "English", "German", "Spanish", "Japanese", "Chinese", "French", "Hindi", "Norwegian"]
  private let screenModes = ["System", "Light", "Dark"]
  private let searchEngines = ["Google", "Bing", "Yahoo", "DuckDuckGo"]
  private let retentionPeriods = ["1 Day", "1 Week", "1 Month", "Indefinite"]
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 24) {
        SettingsRow(title: NSLocalizedString("Language", comment: "")) {
          SettingsDropdown(
            selection: $selectedLanguage,
            options: languages.map { NSLocalizedString($0, comment: "") }
          )
        }
        
        SettingsRow(title: NSLocalizedString("Screen Mode", comment: "")) {
          SettingsDropdown(
            selection: $selectedScreenMode,
            options: screenModes.map { NSLocalizedString($0, comment: "") }
          )
        }
        
        SettingsRow(title: NSLocalizedString("Search Engine", comment: "")) {
          SettingsDropdown(
            selection: $selectedSearchEngine,
            options: searchEngines
          )
        }
        
        SettingsRow(title: NSLocalizedString("Retention Period", comment: "")) {
          SettingsDropdown(
            selection: $selectedRetentionPeriod,
            options: retentionPeriods.map { NSLocalizedString($0, comment: "") }
          )
        }
      }
      
      VStack(spacing: 16) {
        Button(action: {
          isTrackerBlocking.toggle()
        }) {
          HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
              HStack(spacing: 6) {
                Image(systemName: isTrackerBlocking ? "checkmark.square.fill" : "square")
                  .font(.system(size: 16))
                  .foregroundColor(isTrackerBlocking ? Color("Point") : Color("Icon"))
                
                Text(NSLocalizedString("Tracker Blocking", comment: ""))
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(Color("UIText"))
              }
              
              Text(NSLocalizedString("Blocks unnecessary ads and trackers using DuckDuckGo’s tracking protection list along with additional rules.", comment: ""))
                .font(.system(size: 13))
                .foregroundColor(Color("UIText").opacity(0.7))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 2)
              
              // Learn More 링크 추가
              Button(action: {
                browser.newTab(URL(string: "https://github.com/opacity-browser/ContentBlockRuleList")!)
              }) {
                Text(NSLocalizedString("Learn More", comment: ""))
                  .font(.system(size: 12))
                  .foregroundColor(Color("Point"))
                  .underline()
              }
              .buttonStyle(.plain)
              .padding(.leading, 2)
              .padding(.top, 4)
            }
            
            Spacer()
          }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
      }
      
      Spacer()
    }
    .onAppear {
      loadCurrentSettings()
    }
    .onChange(of: selectedLanguage) { _, newValue in
      updateLanguage(newValue)
    }
    .onChange(of: selectedScreenMode) { _, newValue in
      updateScreenMode(newValue)
    }
    .onChange(of: selectedSearchEngine) { _, newValue in
      updateSearchEngine(newValue)
    }
    .onChange(of: selectedRetentionPeriod) { _, newValue in
      updateRetentionPeriod(newValue)
    }
    .onChange(of: isTrackerBlocking) { _, newValue in
      updateTrackerBlocking(newValue)
    }
  }
  
  private func loadCurrentSettings() {
    guard let settings = generalSettings.first else { return }
    
    selectedScreenMode = mapScreenMode(settings.screenMode)
    selectedSearchEngine = settings.searchEngine
    selectedRetentionPeriod = mapRetentionPeriod(settings.retentionPeriod)
    isTrackerBlocking = settings.isTrackerBlocking
    
    // 현재 언어 가져오기
    let currentLanguage = Locale.current.language.languageCode?.identifier ?? "ko"
    selectedLanguage = mapLanguageCode(currentLanguage)
  }
  
  private func mapScreenMode(_ mode: String) -> String {
    switch mode {
    case "Light": return NSLocalizedString("Light", comment: "")
    case "Dark": return NSLocalizedString("Dark", comment: "")
    case "System": return NSLocalizedString("System", comment: "")
    default: return NSLocalizedString("System", comment: "")
    }
  }
  
  private func mapRetentionPeriod(_ period: String) -> String {
    switch period {
    case "1 Day": return NSLocalizedString("1 Day", comment: "")
    case "1 Week": return NSLocalizedString("1 Week", comment: "")
    case "1 Month": return NSLocalizedString("1 Month", comment: "")
    case "Indefinite": return NSLocalizedString("Indefinite", comment: "")
    default: return NSLocalizedString("1 Week", comment: "")
    }
  }
  
  private func mapLanguageCode(_ code: String) -> String {
    switch code {
    case "ko": return NSLocalizedString("Korean", comment: "")
    case "en": return NSLocalizedString("English", comment: "")
    case "de": return NSLocalizedString("German", comment: "")
    case "es": return NSLocalizedString("Spanish", comment: "")
    case "ja": return NSLocalizedString("Japanese", comment: "")
    case "zh": return NSLocalizedString("Chinese", comment: "")
    case "fr": return NSLocalizedString("French", comment: "")
    case "hi": return NSLocalizedString("Hindi", comment: "")
    case "no": return NSLocalizedString("Norwegian", comment: "")
    default: return NSLocalizedString("Korean", comment: "")
    }
  }
  
  private func updateLanguage(_ language: String) {
    let languageCode: String
    switch language {
    case NSLocalizedString("Korean", comment: ""): languageCode = "ko"
    case NSLocalizedString("English", comment: ""): languageCode = "en"
    case NSLocalizedString("German", comment: ""): languageCode = "de"
    case NSLocalizedString("Spanish", comment: ""): languageCode = "es"
    case NSLocalizedString("Japanese", comment: ""): languageCode = "ja"
    case NSLocalizedString("Chinese", comment: ""): languageCode = "zh"
    case NSLocalizedString("French", comment: ""): languageCode = "fr"
    case NSLocalizedString("Hindi", comment: ""): languageCode = "hi"
    case NSLocalizedString("Norwegian", comment: ""): languageCode = "no"
    default: languageCode = "ko"
    }
    
    UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
  }
  
  private func updateScreenMode(_ mode: String) {
    let modeValue: String
    switch mode {
    case NSLocalizedString("Light", comment: ""): modeValue = "Light"
    case NSLocalizedString("Dark", comment: ""): modeValue = "Dark"
    case NSLocalizedString("System", comment: ""): modeValue = "System"
    default: modeValue = "System"
    }
    
    SettingsManager.setScreenMode(modeValue)
  }
  
  private func updateSearchEngine(_ engine: String) {
    SettingsManager.setSearchEngine(engine)
  }
  
  private func updateRetentionPeriod(_ period: String) {
    let periodValue: String
    switch period {
    case NSLocalizedString("1 Day", comment: ""): periodValue = "1 Day"
    case NSLocalizedString("1 Week", comment: ""): periodValue = "1 Week"
    case NSLocalizedString("1 Month", comment: ""): periodValue = "1 Month"
    case NSLocalizedString("Indefinite", comment: ""): periodValue = "Indefinite"
    default: periodValue = "1 Week"
    }
    
    SettingsManager.setRetentionPeriod(periodValue)
  }
  
  private func updateTrackerBlocking(_ isEnabled: Bool) {
    SettingsManager.setIsTrackerBlocking(isEnabled)
    AppDelegate.shared.service.isTrackerBlocking = isEnabled
  }
}
