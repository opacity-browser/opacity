////
////  WebviewView.swift
////  FriedEgg
////
////  Created by Falsy on 1/23/24.
////
//
//import SwiftUI
//
//struct WebviewView: View {
//  @Binding var tabs: [Tab]
//  @Binding var activeTabIndex: Int
//  @ObservedObject var tab: Tab
//  var index: Int
//  @Binding var progress: Double
//  
//  var body: some View {
//    Webview(tabs: $tabs, activeTabIndex: $activeTabIndex, tab: tabs[index], progress: $progress)
//      .zIndex(index == activeTabIndex ? Double(tabs.count) : 0)
//  }
//}
