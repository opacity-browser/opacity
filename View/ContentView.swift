import SwiftUI

struct ContentView: View {
  @EnvironmentObject var service: Service
  @EnvironmentObject var browser: Browser
  
  var tabId: UUID?

  @State private var isAddHover: Bool = false
  @State private var progress: Double = 0.0
  @State private var showProgress: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      // tab bar area
      if browser.tabs.count > 0 {
        TitlebarView(service: service, tabs: $browser.tabs, activeTabId: $browser.activeTabId, progress: $progress, showProgress: $showProgress)
          .frame(maxWidth: .infinity)
          .onChange(of: progress) { _, newValue in
            if newValue == 1.0 {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showProgress = false
                progress = 0.0
              }
            } else if newValue > 0.0 && newValue < 1.0 {
              showProgress = true
            }
          }
      }
      if let _ = browser.activeTabId {
        MainView(tabs: $browser.tabs, activeTabId: $browser.activeTabId, progress: $progress)
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
        let newTab = Tab(url: DEFAULT_URL)
        browser.tabs.append(newTab)
        browser.activeTabId = newTab.id
        return
      }
      
      for (_, targetBrowser) in service.browsers {
        print("service 반복")
        if let targetTabIndex = targetBrowser.tabs.firstIndex(where: { $0.id == baseTabId }) {
          print("초기 tab index: \(targetTabIndex)")
          print("타겟 브라우저 탭 정보 1: \(targetBrowser.tabs.count)")
          let targetTab = targetBrowser.tabs[targetTabIndex]
          browser.tabs.append(targetTab)
          browser.activeTabId = targetTab.id
          print("새로운 브라우저에 base Tab ID의 탭 추가")
          targetBrowser.tabs.remove(at: targetTabIndex)
          print("타겟 브라우저 탭 정보 2: \(targetBrowser.tabs.count)")
          if targetBrowser.tabs.count > 0 {
            targetBrowser.activeTabId = targetBrowser.tabs[targetBrowser.tabs.count - 1].id
          }
          break
        }
      }
    }
  }
}
