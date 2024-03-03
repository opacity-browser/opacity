import SwiftUI
import SwiftData

struct ContentView: View {
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?
  var width: CGFloat
  
  @State private var windowWidth: CGFloat?
  @State private var isMoreTabDialog = false
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        if browser.tabs.count > 0, let activeTabId = browser.activeTabId {
          VStack(spacing: 0) {
            // search area
            Rectangle()
              .frame(height: 1)
              .foregroundColor(Color("UIBorder"))
            Rectangle()
              .frame(height: 3.5)
              .foregroundColor(Color("SearchBarBG"))
            if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
              SearchView(tab: activeTab)
                .frame(maxWidth: .infinity,  maxHeight: 41)
                .background(Color("SearchBarBG"))
                .background(.blue)
              Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color("UIBorder"))
            }
            MainView(browser: browser)
              .onChange(of: geometry.size) { _, newValue in
                windowWidth = geometry.size.width
              }
              .onAppear {
                windowWidth = geometry.size.width
              }
          }
        }
      }
    }
    .toolbar {
      if let width = windowWidth {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            TitlebarView(width: $windowWidth, service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
            Spacer()
            Button(action: {
              self.isMoreTabDialog.toggle()
            }) {
              Image(systemName: "rectangle.stack")
                .popover(isPresented: $isMoreTabDialog, arrowEdge: .bottom) {
                  TabDialog(service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
                }
            }
          }
          .frame(width: width - 90, height: 38)
        }
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
