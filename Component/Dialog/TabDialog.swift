//
//  TabDialog.swift
//  Opacity
//
//  Created by Falsy on 2/15/24.
//

import SwiftUI

struct TabDialog: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  
  @State private var searchText: String = ""
  
  var filteredItems: [Tab] {
    if searchText.isEmpty {
      return tabs
    } else {
      return tabs.filter { tab in
        tab.title.localizedCaseInsensitiveContains(searchText) ||
        tab.originURL.absoluteString.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      
      HStack(spacing: 0) {
        HStack(spacing: 0) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 13))
            .frame(width: 30, height: 30, alignment: .center)
          TextField(NSLocalizedString("Search..", comment: ""), text: $searchText)
            .foregroundColor(.white.opacity(0.85))
            .textFieldStyle(PlainTextFieldStyle())
            .frame(alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .frame(height: 30)
        .padding(2)
        .background(Color("SearchBarBG"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .padding(10)
      
      Divider()
      
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(spacing: 0) {
            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, tab in
              TabDialogItemNSView(service: service, browser: browser, tabs: $tabs, tab: tab, activeTabId: $activeTabId, index: index)
            }
            Spacer()
          }
          .padding(.vertical, 5)
        }
        .frame(width: 240, height: 400)
      }
    }
    .frame(width: 240)
    .background(GeometryReader { geometry in
      Color("DialogBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
}
