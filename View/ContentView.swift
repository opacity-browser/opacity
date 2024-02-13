import SwiftUI

struct ContentView: View {
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?

  @State private var isAddHover: Bool = false
//  @State private var progress: Double = 0.0
  @State private var showProgress: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      // tab bar area
      if browser.tabs.count > 0, let tab = getTab() {
        TitlebarView(service: service, tabs: $browser.tabs, activeTabId: $browser.activeTabId, showProgress: $showProgress)
          .frame(maxWidth: .infinity)
          .onChange(of: tab.pageProgress) { _, newValue in
            if newValue == 1.0 {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showProgress = false
                tab.pageProgress = 0.0
              }
            } else if newValue > 0.0 && newValue < 1.0 {
              showProgress = true
            }
          }
      }
      if let _ = browser.activeTabId {
//        MainView(browser: browser, activeTabId: $browser.activeTabId, progress: $progress)
        MainView(browser: browser)
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Spacer()
        Button(action: {
          // 버튼 액션
        }) {
          Image(systemName: "rectangle.stack") // 아이콘 지정
        }
      }
    }
    .ignoresSafeArea(.container, edges: .top)
    .onAppear {
      guard let baseTabId = tabId else {
        browser.newTab()
        return
      }
      
      for (_, targetBrowser) in service.browsers {
        if let targetTabIndex = targetBrowser.tabs.firstIndex(where: { $0.id == baseTabId }) {
          let targetTab = targetBrowser.tabs[targetTabIndex]
          browser.tabs.append(targetTab)
          browser.activeTabId = targetTab.id
          targetBrowser.tabs.remove(at: targetTabIndex)
          if targetBrowser.tabs.count > 0 {
            targetBrowser.activeTabId = targetBrowser.tabs[targetBrowser.tabs.count - 1].id
          }
          break
        }
      }
    }
  }
  
  func getTab() -> Tab? {
    let tab = browser.tabs.first(where: { $0.id == browser.activeTabId })
    return tab != nil ? tab : nil
  }
}
