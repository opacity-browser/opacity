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
  @Binding var progress: Double
  @Binding var showProgress: Bool
  
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {

        VStack { }.frame(width: 74)
        
        HStack(spacing: 0) {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
            BrowserTabView(service: service, tabs: $tabs, tab: tab, isActive: tab.id == activeTabId, activeTabId: $activeTabId, index: index, showProgress: $showProgress) {
              tabs.remove(at: index)
              let activeTabIndex = tabs.count > index ? index : tabs.count - 1
              activeTabId = tabs[activeTabIndex].id
              if(tabs.count == 0) {
                NSApplication.shared.keyWindow?.close()
              }
            }
            .contentShape(Rectangle())
          }
        }
        .onAppear {
          activeTabId = tabs[0].id
        }
//        .animation(.linear(duration: 0.15), value: tabs)
        
        Button(action: {
          let newTab = Tab(url: DEFAULT_URL)
          tabs.append(newTab)
          activeTabId = newTab.id
//          let activeTabIndex = tabs.count - 1
//          activeTabId = tabs[activeTabIndex].id
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
        SearchView(tab: activeTab, progress: $progress, showProgress: $showProgress)
          .frame(maxWidth: .infinity,  maxHeight: 40.0)
          .background(Color("MainBlack"))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: 80)
//    .background(.red)
  }
}
