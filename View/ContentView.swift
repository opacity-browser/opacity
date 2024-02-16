import SwiftUI

struct ContentView: View {
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?

  @State private var isMoreTabDialog = false
  @State private var isAddHover: Bool = false
  @State private var showProgress: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      if browser.tabs.count > 0, let _ = browser.activeTabId {
        TitlebarView(service: service, tabs: $browser.tabs, activeTabId: $browser.activeTabId, showProgress: $showProgress)
        MainView(browser: browser)
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Spacer()
        Button(action: {
          self.isMoreTabDialog.toggle()
        }) {
          Image(systemName: "rectangle.stack")
            .popover(isPresented: $isMoreTabDialog, arrowEdge: .bottom) {
              TabDialog(service: service, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
            }
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
              let newTargetTabIndex = targetTabIndex == 0 ? 0 : targetTabIndex - 1
              targetBrowser.activeTabId = targetBrowser.tabs[newTargetTabIndex].id
            }
          }
          break
        }
      }
    }
  }
}
