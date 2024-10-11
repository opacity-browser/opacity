//
//  WindowTitleBar.swift
//  Opacity
//
//  Created by Falsy on 3/5/24.
//

import SwiftUI

struct WindowTitleBarView: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  var isFullScreen: Bool
  
  @State var windowWidth: CGFloat = 0
  @State private var isMoreTabDialog = false
  @State private var isMoreHover: Bool = false
  
  var body: some View {
    ZStack {
      GeometryReader { geometry in
        if isFullScreen {
          Rectangle()
            .frame(width: windowWidth, height: 38)
            .foregroundColor(Color("WindowTitleBG"))
        }
        
        HStack(spacing: 0) {
          WindowTitlebar(width: $windowWidth, service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
            .onAppear {
              windowWidth = geometry.size.width
            }
            .onChange(of: windowWidth) { _, newWidth in
              windowWidth = newWidth
            }
          
          Spacer()
          
          if isFullScreen {
            VStack(spacing: 0) {
              VStack(spacing: 0) {
                Image(systemName: "rectangle.stack")
                  .foregroundColor(Color("Icon"))
                  .font(.system(size: 14))
                  .fontWeight(.regular)
                  .opacity(0.6)
              }
              .frame(maxWidth: 25, maxHeight: 25)
              .background(isMoreHover ? .gray.opacity(0.2) : .gray.opacity(0))
              .clipShape(RoundedRectangle(cornerRadius: 6))
              .onHover { hovering in
                withAnimation {
                  isMoreHover = hovering
                }
              }
              .onTapGesture {
                self.isMoreTabDialog.toggle()
              }
              .popover(isPresented: $isMoreTabDialog, arrowEdge: .bottom) {
                TabDialog(service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
              }
              .padding(.trailing, 10)
            }
          } else {
            Button {
              self.isMoreTabDialog.toggle()
            } label: {
              Image(systemName: "rectangle.stack")
                .popover(isPresented: $isMoreTabDialog, arrowEdge: .bottom) {
                  TabDialog(service: service, browser: browser, tabs: $browser.tabs, activeTabId: $browser.activeTabId)
                }
            }
          }
        }
      }
    }
    .frame(height: 38)
  }
}
