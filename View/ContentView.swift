import SwiftUI

struct ContentView: View {
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?

  @State private var isAddHover: Bool = false
  @State private var showProgress: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      if browser.tabs.count > 0, let _ = browser.activeTabId {
        TitlebarView(service: service, tabs: $browser.tabs, activeTabId: $browser.activeTabId, showProgress: $showProgress)
          .frame(maxWidth: .infinity)
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
          DispatchQueue.main.async {
            browser.tabs.append(targetTab)
            browser.activeTabId = targetTab.id
            
            targetBrowser.tabs.remove(at: targetTabIndex)
            if targetBrowser.tabs.count > 0 {
              targetBrowser.activeTabId = targetBrowser.tabs[targetBrowser.tabs.count - 1].id
            }
          }
          break
        }
      }
    }
  }
}
