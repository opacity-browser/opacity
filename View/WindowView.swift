////
////  WindowView.swift
////  Opacity
////
////  Created by Falsy on 1/16/24.
////
//
//import SwiftUI
//
//struct WindowView: View {
//  @Binding var tabs: [Tab]
//  @Binding var activeTabIndex: Int
//  
//    var body: some View {
//      GeometryReader { geometry in
//        ContentView(tabs: $tabs, activeTabIndex: $activeTabIndex)
//          .frame(minWidth: 1024, minHeight: 800, alignment: .center)
//      }
//    }
//}
//
//#Preview {
//    WindowView()
//}
