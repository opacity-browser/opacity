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
  @State var isDeleteHover: Bool = false
  
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
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "xmark")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 12))
              .fontWeight(.regular)
          }
          .frame(maxWidth: 22, maxHeight: 22)
          .background(isDeleteHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { inside in
            withAnimation {
              isDeleteHover = inside
            }
          }
          .onTapGesture {
            SearchManager.deleteSearchHistoryGroup(searchHistoryGroup)
            tab.autoCompleteList = tab.autoCompleteList.filter {
              $0.id != searchHistoryGroup.id
            }
            if isActive && tab.autoCompleteList.count > 0 {
              tab.autoCompleteIndex = 0
            }
          }
        }
        .padding(.trailing, 11)
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
