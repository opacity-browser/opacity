//
//  SearchAutoCompleteItem.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI

struct SearchAutoCompleteItem: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var searchHistoryGroup: SearchHistoryGroup
  var isActive: Bool
  
  @State var isHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Image(systemName: "rectangle.and.pencil.and.ellipsis.rtl")
          .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
          .font(.system(size: 12))
          .foregroundColor(Color("Icon").opacity(0.8))
          .padding(.leading, 8)
          .offset(y: -1)
        Text(searchHistoryGroup.searchText)
          .padding(.leading, 5)
          .opacity(0.8)
        Spacer()
      }
      .frame(height: 30)
    }
    .onHover { hovering in
      withAnimation {
        isHover = hovering
      }
    }
    .background(Color("AutoCompleteHover").opacity(isActive ? 0.6 : isHover ? 0.4 : 0))
    .onTapGesture {
      tab.searchInSearchBar(searchHistoryGroup.searchText)
    }
  }
}
