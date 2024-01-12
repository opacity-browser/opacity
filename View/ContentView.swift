//import SwiftUI
//import WebKit
//
//// 웹뷰 인스턴스를 관리하는 클래스
//class WebViewManager {
//    static let shared = WebViewManager()
//    private var webViews: [UUID: WKWebView] = [:]
//
//  func webView(id: UUID, url: String) -> WKWebView {
//    if let webView = webViews[id] {
//      return webView
//    } else {
//      let newWebView = WKWebView()
//      newWebView.load(URLRequest(url: URL(string: url)!))
//      webViews[id] = newWebView
//      return newWebView
//    }
//  }
//}
//
//// WKWebView를 SwiftUI 뷰로 만드는 구조체
//struct WebView: NSViewRepresentable {
//    @Binding var tab: Tab
//
//    func makeNSView(context: Context) -> WKWebView {
//      WebViewManager.shared.webView(id: tab.id, url: tab.webURL)
//    }
//
//    func updateNSView(_ nsView: WKWebView, context: Context) {
//        // 필요한 업데이트 로직
//    }
//}
//
//// 메인 뷰
//struct ContentView: View {
//  @ObservedObject var browser: Browser = Browser()
//  @State private var activeTabIndex: Int = 0
//
//  var body: some View {
//    VStack {
//      
//      BrowserTabView(activeTabIndex: $activeTabIndex)
//      
////      ForEach(browser.tabs.indices, id: \.self) { index in
////        BrowserTab(siteTitle: $browser.tabs[index].title, isActive: index == activeTabIndex)
////        {
////          print("close")
////        }
////        .onTapGesture {
////          activeTabIndex = index
////        }
////        Image(systemName: "poweron")
////          .frame(width: 2)
////          .opacity(0.2)
////      }
//
//      ForEach(0..<2) { index in
//        if activeTabIndex == index {
//          WebView(tab: $browser.tabs[index])
//        }
//      }
//    }
//  }
//}

//
//  ContentView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct ContentView: View {
  @State private var viewSize: CGSize = .zero
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        NavigationSplitView {
          SidebarView()
        } detail: {
          MainView(viewSize: $viewSize)
        }
      }
      .onChange(of: geometry.size) { oldValue, newValue in
        self.viewSize = newValue
      }
    }
    .frame(minWidth: 520)
  }
}

#Preview {
  ContentView()
}
