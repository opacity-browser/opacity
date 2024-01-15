//
//  MainView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct MainView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  
  var body: some View {
    VStack(spacing: 0) {
      // search area
      if(tabs.count > 0) {
        HStack {
          SearchView(tab: $tabs[activeTabIndex])
        }
        .frame(maxWidth: .infinity,  maxHeight: 36.0)
        .background(colorScheme == .dark ? .black.opacity(0.1) : .gray.opacity(0.5))
        
      }
      
      Divider()
        .border(.black.opacity(0.9))
      
      // webview area
      ZStack {
        if(tabs.count > 0) {
          ForEach(tabs.indices, id: \.self) { index in
            Webview(tab: $tabs[index]).zIndex(index == activeTabIndex ? Double(tabs.count) : 0)
          }
        }
      }
    }
    .multilineTextAlignment(.leading)
  }
}
