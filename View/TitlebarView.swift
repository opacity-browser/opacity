//
//  TitlebarView.swift
//  Opacity
//
//  Created by Falsy on 1/15/24.
//

import SwiftUI

struct TitlebarView: View {
  @Environment(\.colorScheme) var colorScheme

  @ObservedObject var service: Service
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  @Binding var showProgress: Bool
  
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {

        VStack { }.frame(width: 74)
        
        HStack(spacing: 0) {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
            BrowserTabView(service: service, tabs: $tabs, tab: tab, activeTabId: $activeTabId, index: index, showProgress: $showProgress) {
              AppDelegate.shared.closeTab()
            }
            .contentShape(Rectangle())
          }
        }
        .onAppear {
          activeTabId = tabs[0].id
        }
        
        Button(action: {
          if let keyWindow = NSApplication.shared.keyWindow {
            let windowNumber = keyWindow.windowNumber
            if let target = self.service.browsers[windowNumber] {
              target.newTab()
            }
          }
        }) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 24, maxHeight: 24)
            .background(isAddHover ? .gray.opacity(0.2) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.top, 1)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { isHover in
          withAnimation {
            isAddHover = isHover
          }
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: 36, alignment: .leading)
      
      Divider()
        .frame(maxWidth: .infinity, maxHeight: 2)
        .border(Color("MainBlack"))
        .offset(y: 1)
      Divider()
        .frame(maxWidth: .infinity, maxHeight: 2)
        .border(Color("MainBlack"))
        .offset(y: 1)
      
      // search area
      if let activeTab = tabs.first(where: { $0.id == activeTabId }) {
        SearchView(tab: activeTab, showProgress: $showProgress)
          .frame(maxWidth: .infinity,  maxHeight: 40.0)
          .background(Color("MainBlack"))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: 80)
//    .background(.red)
  }
}
