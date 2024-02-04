import SwiftUI

struct ContentView: View {
  @EnvironmentObject var browser: Browser

  @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
  @State var windowWidth: CGFloat = .zero
  @State private var isAddHover: Bool = false
  @State private var progress: Double = 0.0
  @State private var showProgress: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // tab bar area
        if browser.tabs.count > 0 {
          TitlebarView(tabSize: $browser.tabSize, tabs: $browser.tabs, activeTabIndex: $browser.index, progress: $progress, showProgress: $showProgress)
            .frame(maxWidth: .infinity, maxHeight: 38)
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
        MainView(tabs: $browser.tabs, activeTabIndex: $browser.index, progress: $progress)
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
      .onChange(of: geometry.size) { oldValue, newValue in
        windowWidth = newValue.width
      }
      .ignoresSafeArea(.container, edges: .top)
      .onAppear {
        if browser.tabs.count == 0 {
          let newTab = Tab(url: DEFAULT_URL)
          browser.tabs.append(newTab)
          browser.index = 0
        }
      }
    }
  }
}
