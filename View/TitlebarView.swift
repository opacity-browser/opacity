//
//  TitlebarView.swift
//  Opacity
//
//  Created by Falsy on 1/15/24.
//

import SwiftUI

struct TitlebarView: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var tabSize: CGSize?
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @Binding var progress: Double
  @Binding var showProgress: Bool
  
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {

        VStack { }.frame(width: 74)
        
        HStack(spacing: 0) {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, _ in
            BrowserTabView(tabSize: $tabSize, tab: tabs[index], isActive: index == activeTabIndex, activeTabIndex: $activeTabIndex, index: index, showProgress: $showProgress) {
              tabs.remove(at: index)
              activeTabIndex = tabs.count > index ? index : tabs.count - 1
              if(tabs.count == 0) {
                NSApplication.shared.keyWindow?.close()
              }
            }
            .contentShape(Rectangle())
            .onTapGesture {
              activeTabIndex = index
            }
            .gesture(
              DragGesture()
                .onChanged({ value in
                  print(value.location)
                })
            )
          }
        }
        .animation(.linear(duration: 0.15), value: tabs)
        
        Button(action: {
          let newTab = Tab(url: DEFAULT_URL)
          tabs.append(newTab)
          activeTabIndex = tabs.count - 1
        }) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 24, maxHeight: 24)
            .background(isAddHover ? .gray.opacity(0.2) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.top, 1)
//        .padding(.leading, 5)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { isHover in
          withAnimation {
            isAddHover = isHover
          }
        }
        
        Spacer()
      }
      .animation(.linear(duration: 0.1), value: tabs)
      .frame(maxWidth: .infinity, maxHeight: 36, alignment: .leading)
      
      Divider()
        .frame(maxWidth: .infinity, maxHeight: 2)
        .border(Color("MainBlack"))
        .offset(y: 1)
//      Divider()
//        .frame(maxWidth: .infinity, maxHeight: 2)
//        .border(Color("MainBlack"))
//        .offset(y: 1)
    }
    
    // search area
    SearchView(tab: tabs[activeTabIndex], progress: $progress, showProgress: $showProgress)
      .frame(maxWidth: .infinity,  maxHeight: 37.0)
      .background(Color("MainBlack"))
  }
}
