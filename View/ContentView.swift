import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var searchHistoryGroup: [SearchHistoryGroup]
    @Query var searchHistory: [SearchHistory]
  
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
      GeometryReader { geometry in
        if let _ = browser.activeTabId, browser.tabs.count > 0 {
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
        }
      }
      if let tab = browser.tabs.first(where: { $0.id == browser.activeTabId }) {
        SearchBoxDialog(browser: browser, tab: tab)
      }
    }
    .toolbar {
      if let _ = browser.activeTabId, browser.tabs.count > 0, !windowDelegate.isFullScreen {
        WindowTitleBarView(windowWidth: $windowWidth, service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId, isFullScreen: windowDelegate.isFullScreen)
      }
    }
    .onAppear {
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
