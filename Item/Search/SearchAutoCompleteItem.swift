//
//  SearchAutoCompleteItem.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI

struct SearchAutoCompleteItem: View {
  var searchHistoryGroup: SearchHistoryGroup
  @State var isHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(searchHistoryGroup.searchText)
        Text("-")
        Text("\(searchHistoryGroup.searchHistories!.count)")
        Spacer()
      }
      .padding(.horizontal, 15)
      .frame(height: 32)
    }
//    .padding(.vertical, 7)
    .onHover { hovering in
      withAnimation {
        isHover = hovering
      }
    }
    .background(Color("InputBG").opacity(isHover ? 0.5 : 0))
//    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
