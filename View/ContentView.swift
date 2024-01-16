import SwiftUI

struct ContentView: View {
//  @State private var viewSize: CGSize = .zero
  @State var tabs: [Tab] = []
  @State var activeTabIndex: Int = -1
  @State var windowWidth: CGFloat = .zero
  @State private var isAddHover: Bool = false
  @State var titleSafeWidth: CGFloat = .zero
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // tab bar area
        TitlebarView(tabs: $tabs, activeTabIndex: $activeTabIndex, titleSafeWidth: $titleSafeWidth)
          .frame(maxWidth: .infinity, maxHeight: 38)
        
//        Divider()
        
        NavigationSplitView {
          SidebarView()
            .navigationSplitViewColumnWidth(min: 180, ideal: 180)
        } detail: {
          MainView(tabs: $tabs, activeTabIndex: $activeTabIndex)
        }
      }
      .onChange(of: geometry.size) { oldValue, newValue in
        windowWidth = newValue.width
      }
      .ignoresSafeArea(.container, edges: .top)
      .frame(minWidth: 520)
      .onAppear {
        let newTab = Tab(webURL: DEFAULT_URL)
        tabs.append(newTab)
        activeTabIndex = 0
      }
    }
  }
}
