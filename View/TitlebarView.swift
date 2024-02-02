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
  @Binding var progress: Double
  @Binding var showProgress: Bool
  
  @State private var isAddHover: Bool = false
  
  // drag&drop
  @State private var cacheTabs: [Tab]?
  @State private var cacheIndex: Int?
  @State private var dragIndex = 0
  @State private var enterIndex = -1
  @State private var isDrop: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {

        VStack { }.frame(width: 74)
        
        HStack(spacing: 0) {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, _ in
            BrowserTabView(tab: tabs[index], isActive: index == activeTabIndex, showProgress: $showProgress) {
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
            .onDrag {
              dragIndex = index
              print("drag")
//              return NSItemProvider(object: tabs[index].title as NSString as NSItemProviderWriting)
              return NSItemProvider(object: NSString(string: ""))
            }
            .onDrop(of: ["public.utf8-plain-text"], delegate: TabDropDelegate(
              onEnter: { _ in
                print("enter")
//                isDrop = false
//                enterIndex = index
//                cacheTabs = tabs
//                cacheIndex = activeTabIndex
                activeTabIndex = index
                withAnimation {
                  tabs.move(fromOffsets: Foundation.IndexSet(integer: dragIndex), toOffset: dragIndex > index ? index : index + 1)
                  dragIndex = index
                }
              }, onExit: { _ in
                print("exit")
//                enterIndex = -1
//                if isDrop == false, let cacheTabsData = cacheTabs, let cacheIndexData = cacheIndex {
//                  tabs = cacheTabsData
//                  activeTabIndex = cacheIndexData
//                }
              }, onDrop: { _ in
                print("drop")
//                isDrop = true
              }
            ))
          }
        }
        .animation(.linear(duration: 0.2), value: tabs)
        
        Button(action: {
          let newTab = Tab(url: DEFAULT_URL)
          tabs.append(newTab)
          activeTabIndex = tabs.count - 1
        }) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .frame(maxWidth: 26, maxHeight: 26)
            .background(isAddHover ? .gray.opacity(0.2) : .gray.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.top, 2)
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
      .frame(maxWidth: .infinity, maxHeight: 36, alignment: .leading)
//      .background(.blue.opacity(0.2))
      
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
    SearchView(tab: tabs[activeTabIndex], progress: $progress, showProgress: $showProgress)
      .frame(maxWidth: .infinity,  maxHeight: 37.0)
      .background(Color("MainBlack"))
  }
}


struct TabDropDelegate: DropDelegate {
  var onEnter: (DropInfo)->Void
  var onExit: (DropInfo)->Void
  var onDrop: (DropInfo)->Void
  
  func dropEntered(info: DropInfo) {
    onEnter(info)
  }
  
  func dropExited(info: DropInfo) {
    onExit(info)
  }
  
  func performDrop(info: DropInfo) -> Bool {
    onDrop(info)
    return true
  }
}
