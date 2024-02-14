//
//  TestContentView.swift
//  FriedEgg
//
//  Created by Falsy on 2/13/24.
//

import SwiftUI
import WebKit

struct TestContentView: View {
  @State private var webView: WKWebView = WKWebView()
      
      var body: some View {
          VStack {
              WebView(webView: webView)
//                  .frame(height: 300)
                  .onAppear {
                      let request = URLRequest(url: URL(string: "https://www.github.com")!)
                      webView.load(request)
                  }
              
              Button("Open in New Window") {
                  self.openWebViewInNewWindow()
              }
          }
      }
      
      func openWebViewInNewWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 1400, height: 800)
          let newWindow = NSWindow(
              contentRect: windowRect,
              styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
              backing: .buffered, defer: false)
          newWindow.center()
          newWindow.title = "New WebView Window"
          
          // SwiftUI 뷰를 NSView로 변환하여 NSWindow에 직접 추가하는 대신,
          // NSHostingView를 사용하여 SwiftUI 뷰를 콘텐츠 뷰로 설정합니다.
          let hostingView = NSHostingView(rootView: WebView(webView: webView))
          newWindow.contentView = hostingView
          
          newWindow.makeKeyAndOrderFront(nil)
          NSApp.activate(ignoringOtherApps: true)
      }
  }
