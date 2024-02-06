//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
//  @Environment(\.colorScheme) var colorScheme
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @Binding var progress: Double
  
  var body: some View {
    VStack(spacing: 0) {
      // webview area
//      DraggableNSView()
//                  .onDrop(of: ["public.utf8-plain-text"], delegate: DropDelegateImpl())
      ZStack {
        if tabs.count > 0 {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, item in
//            WebviewView(tabs: $tabs, activeTabIndex: $activeTabIndex, tab: tabs[activeTabIndex], index: index, progress: $progress)
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}


struct DropDelegateImpl: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        // SwiftUI에서의 드랍 처리
      print("dddrrroopp")
        return true
    }
}
