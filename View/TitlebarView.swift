//
//  TitlebarView.swift
//  Opacity
//
//  Created by Falsy on 1/15/24.
//

import SwiftUI

struct TitlebarView: View {
  @Environment(\.colorScheme) var colorScheme
  
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @Binding var titleSafeWidth: CGFloat
  @State private var isAddHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        //      VStack { }.frame(width: titleSafeWidth).background(.blue)
        VStack { }.frame(width: 119)
        
        HStack(spacing: 0) {
          if tabs.count > 0 {
            ForEach(tabs.indices, id: \.self) { index in
              BrowserTabView(title: $tabs[index].title, isActive: index == activeTabIndex) {
                tabs.remove(at: index)
                activeTabIndex = tabs.count > index ? index : tabs.count - 1
              }
              .contentShape(Rectangle())
//              .background(.red.opacity(0.2))
              .onTapGesture {
                activeTabIndex = index
                print(tabs[activeTabIndex].id)
              }
            }
          }
        }
        
        Button(action: {
          let newTab = Tab(webURL: DEFAULT_URL)
          tabs.append(newTab)
          activeTabIndex = tabs.count - 1
        }) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 24, maxHeight: 24)
            .background(isAddHover ? .gray.opacity(0.1) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .padding(.top, 2)
        .padding(.leading, 10)
        .buttonStyle(.plain)
//        .offset(x: CGFloat(tabs.count * -15))
        .contentShape(Rectangle())
        .onHover { isHover in
          withAnimation {
            isAddHover = isHover
          }
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: 38, alignment: .leading)
//      .background(.blue)
      
      Divider()
        .frame(maxWidth: .infinity, maxHeight: 2)
        .border(Color("MainBlack"))
        .offset(y: 1)
      Divider()
        .frame(maxWidth: .infinity, maxHeight: 2)
        .border(Color("MainBlack"))
        .offset(y: 1)
    }
    
    // search area
    if(tabs.count > 0) {
      SearchView(tab: $tabs[activeTabIndex])
        .frame(maxWidth: .infinity,  maxHeight: 36.0)
        .background(Color("MainBlack"))
    }
  }
}
