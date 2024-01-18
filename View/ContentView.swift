import SwiftUI

struct ContentView: View {
  @EnvironmentObject var browser: Browser

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
        // nav area
        NavigationSplitView {
          SidebarView()
            .navigationSplitViewColumnWidth(min: 180, ideal: 180)
            .toolbar(removing: .sidebarToggle)
        } detail: {
          MainView(tabs: $browser.tabs, activeTabIndex: $browser.index)
        }
        .toolbar {
          ToolbarItem(placement: .navigation) {
            SidebarButton()
          }
        }
      }
      .onChange(of: geometry.size) { oldValue, newValue in
        windowWidth = newValue.width
      }
      .ignoresSafeArea(.container, edges: .top)
      .frame(minWidth: 520)
      .onAppear {
        if browser.tabs.count == 0 {
          let newTab = Tab(webURL: DEFAULT_URL)
          browser.tabs.append(newTab)
          browser.index = 0
        }
      }
    }
  }
}
