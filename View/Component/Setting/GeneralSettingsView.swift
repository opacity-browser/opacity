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
  
  @State private var selectedLanguage: String = "English"
  @State private var selectedScreenMode: String = "System"
  @State private var selectedSearchEngine: String = "Google"
  @State private var selectedRetentionPeriod: String = "1 Week"
  @State private var isTrackerBlocking: Bool = true
  
  // 각 언어를 해당 언어로 표시
  private let languageOptions = [
    ("English", "English"),
    ("Norwegian", "Norsk"),
    ("Hindi", "हिन्दी"),
    ("Korean", "한국어"),
    ("Chinese", "中文"),
    ("German", "Deutsch"),
    ("Japanese", "日本語"),
    ("Spanish", "Español"),
    ("French", "Français")
  ]
  private let screenModes = ["System", "Light", "Dark"]
  private let searchEngines = ["Google", "Bing", "Yahoo", "DuckDuckGo"]
  private let retentionPeriods = ["1 Day", "1 Week", "1 Month", "Indefinite"]
  
  var body: some View {
    VStack(spacing: 32) {
      HStack(spacing: 0) {
        Text(NSLocalizedString("General", comment: ""))
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
        
        Spacer()
      }
      
      VStack(spacing: 28) {
        VStack(spacing: 22) {
          SettingsRow(title: NSLocalizedString("Language", comment: "")) {
            SettingsDropdown(
              selection: $selectedLanguage,
              options: languageOptions.map { $0.1 }  // 각 언어의 네이티브 이름 사용
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
              
              Text(NSLocalizedString("Blocks unnecessary ads and trackers using DuckDuckGo's tracking protection list along with additional rules.", comment: ""))
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
      }
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
    .frame(maxWidth: .infinity, alignment: .topLeading)
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
    case "ko": return "한국어"
    case "en": return "English"
    case "de": return "Deutsch"
    case "es": return "Español"
    case "ja": return "日本語"
    case "zh": return "中文"
    case "fr": return "Français"
    case "hi": return "हिन्दी"
    case "no": return "Norsk"
    default: return "한국어"
    }
  }
  
  private func updateLanguage(_ language: String) {
    let languageCode: String
    switch language {
    case "한국어": languageCode = "ko"
    case "English": languageCode = "en"
    case "Deutsch": languageCode = "de"
    case "Español": languageCode = "es"
    case "日本語": languageCode = "ja"
    case "中文": languageCode = "zh"
    case "Français": languageCode = "fr"
    case "हिन्दी": languageCode = "hi"
    case "Norsk": languageCode = "no"
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
