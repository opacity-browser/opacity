import SwiftUI

struct ContentView: View {
  @EnvironmentObject var browser: Browser

  @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
  @State var windowWidth: CGFloat = .zero
  @State private var isAddHover: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // tab bar area
        if browser.tabs.count > 0 {
          TitlebarView(tabs: $browser.tabs, activeTabIndex: $browser.index)
            .frame(maxWidth: .infinity, maxHeight: 38)
        }
        MainView(tabs: $browser.tabs, activeTabIndex: $browser.index)
      }
      .toolbar {
        ToolbarItemGroup(placement: .primaryAction) {
          Spacer()
          Button(action: {
            // 버튼 액션
          }) {
            Image(systemName: "bell") // 아이콘 지정
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
