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
  
  // drag&drop
  @State private var cacheTabs: [Tab]?
  @State private var cacheIndex: Int?
  @State private var dragIndex = 0
  @State private var enterIndex = -1
  @State private var isDrop: Bool = false
  
  struct TabDropDelegate: DropDelegate {
//    var onEnter: (DropInfo)->Void
//    var onExit: (DropInfo)->Void
    var onDrop: (DropInfo)->Void
    
//    func dropEntered(info: DropInfo) {
//      onEnter(info)
//    }
//
//    func dropExited(info: DropInfo) {
//      onExit(info)
//    }

    func performDrop(info: DropInfo) -> Bool {
      onDrop(info)
      return true
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {

        VStack { }.frame(width: 74)
        
        HStack(spacing: 0) {
          ForEach(Array(tabs.enumerated()), id: \.element.id) { index, _ in
            BrowserTabView(tabSize: $tabSize, tab: tabs[index], isActive: index == activeTabIndex, activeTabIndex: $activeTabIndex, index: index, dragIndex: $dragIndex, showProgress: $showProgress) {
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
//            .onDrag {
//              dragIndex = index
//              print("drag")
//              return NSItemProvider(object: tabs[index].title as NSString as NSItemProviderWriting)
////              return NSItemProvider(object: NSString(string: ""))
//            }
            .onDrop(of: ["public.utf8-plain-text"], delegate: TabDropDelegate(
//              onEnter: { _ in
//                print("enter")
//                withAnimation {
//                  tabs.move(fromOffsets: Foundation.IndexSet(integer: dragIndex), toOffset: dragIndex > index ? index : index + 1)
//                  activeTabIndex = index
//                  dragIndex = index
//                }
//              }, onExit: { _ in
//                print("exit")
//              }, 
              onDrop: { _ in
                print("drop")
              }
            ))
            .gesture(
              DragGesture()
                .onChanged({ value in
                  print(value.location)
                })
            )
          }
        }
//        .animation(.linear(duration: 0.15), value: tabs)
        
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
//      .animation(.linear(duration: 0.1), value: tabs)
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
