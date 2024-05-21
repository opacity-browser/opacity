import SwiftUI
import SwiftData

struct ContentView: View {
  @Query var generalSettings: [GeneralSetting]
  
  @EnvironmentObject var windowDelegate: OpacityWindowDelegate
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?
  var width: CGFloat
  
  @State private var windowWidth: CGFloat?
  @State private var isMoreTabDialog = false
  @State private var isAddHover: Bool = false
  @FocusState private var isTextFieldFocused: Bool
  
  var body: some View {
    ZStack {
      if let _ = browser.activeTabId, browser.tabs.count > 0 {
        GeometryReader { geometry in
          VStack(spacing: 0) {
            if windowDelegate.isFullScreen {
              WindowTitleBarView(windowWidth: $windowWidth, service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId, isFullScreen: true)
            }
            NavigationSearchView(service: service, browser: browser, activeTabId: $browser.activeTabId, isFullScreen: $windowDelegate.isFullScreen)
            MainView(service: service, browser: browser)
              .onChange(of: geometry.size) { _, newValue in
                windowWidth = geometry.size.width
              }
              .onAppear {
                windowWidth = geometry.size.width
              }
          }
          SearchBoxDialog(service: service, browser: browser, activeTabId: $browser.activeTabId, isFullScreen: $windowDelegate.isFullScreen)
        }
      }
    }
    .onAppear {
      if let generalSetting = generalSettings.first {
        print(generalSetting)
        service.blockingLevel = generalSetting.blockingLevel
        service.isAdBlocking = generalSetting.adBlocking
        if generalSetting.screenMode == "Dark" {
          NSApp.appearance = NSAppearance(named: .darkAqua)
        }
        if generalSetting.screenMode == "Light" {
          NSApp.appearance = NSAppearance(named: .aqua)
        }
        if generalSetting.screenMode == "System" {
          NSApp.appearance = nil
        }
      }
    }
    .onChange(of: generalSettings.first?.screenMode) { _, newValue in
      if newValue == "Dark" {
        NSApp.appearance = NSAppearance(named: .darkAqua)
      }
      if newValue == "Light" {
        NSApp.appearance = NSAppearance(named: .aqua)
      }
      if newValue == "System" {
        NSApp.appearance = nil
      }
    }
    .toolbar {
      if let _ = browser.activeTabId, browser.tabs.count > 0, !windowDelegate.isFullScreen {
        WindowTitleBarView(windowWidth: $windowWidth, service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId, isFullScreen: windowDelegate.isFullScreen)
      }
    }
  }
}
