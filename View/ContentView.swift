//
//  ContentView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var siteURL: String = "https://google.com"
  @State private var viewSize: CGSize = .zero
  @State private var isAddHover: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        NavigationSplitView {
          SidebarView()
        } detail: {
          VStack(spacing: 0) {
            // title bar area
            HStack {
              TitleView(viewSize: $viewSize, siteURL: $siteURL)
            }
            .frame(maxWidth: .infinity,  maxHeight: 36.0)
            .background(colorScheme == .dark ? .black.opacity(0.1) : .gray.opacity(0.5))
            
            Divider()
              .border(.black.opacity(0.9))
            
            // tab bar area
            HStack(spacing: 0) {
              ForEach(0..<3){ index in
                TabView(title: "New Tab", isActive: index == 0) {
                  print("action")
                  print("\(index)")
                } onClose: {
                  print("close")
                }
                Image(systemName: "poweron")
                  .frame(width: 2)
                  .opacity(0.2)
              }
              
              VStack {
                Image(systemName: "plus")
                  .font(.system(size: 11))
                  .frame(maxWidth: 19, maxHeight: 19)
                  .background(isAddHover ? .gray.opacity(0.1) : .gray.opacity(0))
                  .clipShape(RoundedRectangle(cornerRadius: 5))
              }
              .padding(.leading, 5)
              .onHover { isHover in
                withAnimation {
                  isAddHover = isHover
                }
              }
              
              Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 26, alignment: .leading)
            
            Divider()
            
            // webview area
            Spacer()
            
            Button("button") {
              
            }
            
            Spacer()
          }
          .ignoresSafeArea(.container, edges: .top)
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
