//
//  ContentView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct ContentView: View {
  @State private var siteURL: String = "https://google.com"
  @State private var viewSize: CGSize = .zero
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        NavigationSplitView {
          SidebarView()
        } detail: {
          VStack(spacing: 0) {
            TitleView(viewSize: $viewSize, siteURL: $siteURL)
              .frame(maxWidth: .infinity, minHeight: 36.0, maxHeight: 36.0)
            Divider()
            
            Spacer()
            Button("button") {
              
            }
            Spacer()
          }
          .ignoresSafeArea(.all, edges: .all)
          .multilineTextAlignment(.leading)
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
