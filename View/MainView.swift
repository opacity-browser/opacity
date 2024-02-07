//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
//  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var service: Service
  var windowNo: Int
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @Binding var progress: Double
  
  var body: some View {
    VStack(spacing: 0) {
      // webview area
      ZStack {
        ForEach(service.browsers.map { $0.key }, id: \.self) { key in
          if let browser = service.browsers[key] {
            ForEach(browser.tabs, id: \.id) { tab in
              //            Text($service.browsers[key]!.tabs[index].title).zIndex(key == windowNo ? 10 : 0)
            }
          }
//            ForEach(Array(service.browsers[key]!.tabs.enumerated()), id: \.element.id) { index, item in
//              Text($service.browsers[key]!.tabs[index].title).zIndex(index == activeTabIndex && key == windowNo ? 10 : 0)
////              Webview(
////                tabs: $service.browsers[key]!.tabs,
////                activeTabIndex: $service.browsers[key]!.index,
////                tab: service.browsers[key]!.tabs[index],
////                progress: $progress
////              ).zIndex(index == activeTabIndex && key == windowNo ? 10 : 0)
//            }
        }
//        if tabs.count > 0 {
//          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, item in
//            Webview(tabs: $tabs, activeTabIndex: $activeTabIndex, tab: tabs[index], progress: $progress)
//              .zIndex(index == activeTabIndex ? Double(tabs.count) : 0)
//          }
//        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
