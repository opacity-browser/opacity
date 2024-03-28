import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) var modelContext
  @Query var opacityBrowserSettings: [OpacityBrowserSettings]
  
  @EnvironmentObject var windowDelegate: OpacityWindowDelegate
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  @ObservedObject var manualUpdate: ManualUpdate = ManualUpdate()
  
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
            NavigationSearchView(browser: browser, activeTabId: $browser.activeTabId, isFullScreen: $windowDelegate.isFullScreen, manualUpdate: manualUpdate)
            MainView(browser: browser, manualUpdate: manualUpdate)
              .onChange(of: geometry.size) { _, newValue in
                windowWidth = geometry.size.width
              }
              .onAppear {
                windowWidth = geometry.size.width
              }
          }
          SearchBoxDialog(browser: browser, activeTabId: $browser.activeTabId, manualUpdate: manualUpdate)
        }
      }
    }
    .onChange(of: opacityBrowserSettings.first?.theme) { _, newValue in
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
    .onAppear {
      if opacityBrowserSettings.count == 0 {
        do {
          modelContext.insert(OpacityBrowserSettings())
          try modelContext.save()
        } catch {
          print("initial browser setup error")
        }
      }
      
      guard let baseTabId = tabId else {
        browser.initTab()
        return
      }
      
      for (_, targetBrowser) in service.browsers {
        if let targetTabIndex = targetBrowser.tabs.firstIndex(where: { $0.id == baseTabId }) {
          let targetTab = targetBrowser.tabs[targetTabIndex]
          browser.tabs.append(targetTab)
          browser.activeTabId = targetTab.id
          
          targetBrowser.tabs.remove(at: targetTabIndex)
          if targetBrowser.tabs.count > 0 {
            let newTargetTabIndex = targetTabIndex == 0 ? 0 : targetTabIndex - 1
            targetBrowser.activeTabId = targetBrowser.tabs[newTargetTabIndex].id
          }
          break
        }
      }
    }
  }
}
