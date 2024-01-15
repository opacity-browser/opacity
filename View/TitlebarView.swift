//
//  TitlebarView.swift
//  Opacity
//
//  Created by Falsy on 1/15/24.
//

import SwiftUI

struct TitlebarView: View {
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  @Binding var titleSafeWidth: CGFloat
  @State private var isAddHover: Bool = false
  
  var body: some View {
    HStack(spacing: 0) {
//      VStack { }.frame(width: titleSafeWidth).background(.blue)
      VStack { }.frame(width: 120)
      
      if tabs.count > 0 {
        ForEach(tabs.indices, id: \.self) { index in
          BrowserTabView(title: $tabs[index].title, isActive: index == activeTabIndex)
          {
            print("close")
            tabs.remove(at: index)
            activeTabIndex = tabs.count - 1
          }
          .onTapGesture {
            activeTabIndex = index
          }
          Image(systemName: "poweron")
            .frame(width: 2)
            .opacity(0.2)
        }
      }
      VStack {
        Button(action: {
          let newTab = Tab(webURL: DEFAULT_URL)
          tabs.append(newTab)
          activeTabIndex = tabs.count - 1
        }, label: {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 19, maxHeight: 19)
            .background(isAddHover ? .gray.opacity(0.1) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        })
        .padding(.leading, 5)
        .onHover { isHover in
          withAnimation {
            isAddHover = isHover
          }
        }
        .buttonStyle(.plain)
        .keyboardShortcut(KeyEquivalent("t"), modifiers: .command)
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: 38, alignment: .leading)
  }
}
