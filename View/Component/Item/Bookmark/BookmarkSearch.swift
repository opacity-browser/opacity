//
//  BookmarkSearch.swift
//  Opacity
//
//  Created by Falsy on 3/14/24.
//

import SwiftUI

struct BookmarkSearch: View {
  @Binding var searchText: String
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        ZStack {
          Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 30)
            .foregroundColor(Color("InputBG").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))

          HStack(spacing: 0) {
            HStack(spacing: 0) {
              Image(systemName: "magnifyingglass")
                .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                .font(.system(size: 13))
                .foregroundColor(Color("Icon"))
            }
            .padding(.leading, 2)
            
            BookmarkNSTextField(searchText: $searchText)
              .padding(.leading, 2)
              .frame(height: 30)
          }
        }
        .padding(1)
        .background(Color("InputBG").opacity(1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
      }
    }
  }
}
