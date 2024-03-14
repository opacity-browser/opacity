//
//  BookmarkSearch.swift
//  Opacity
//
//  Created by Falsy on 3/14/24.
//

import SwiftUI

struct BookmarkSearch: View {
  @FocusState private var isTextFieldFocused: Bool
  @State private var isSearchHover: Bool = false
  @State var isEditSearch: Bool = false
  @Binding var searchText: String
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        ZStack {
          Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 30)
            .foregroundColor(isSearchHover ? Color("InputBGHover").opacity(0.1) : Color("InputBG").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
          
          if isEditSearch {
            HStack(spacing: 0) {
              HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                  .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                  .font(.system(size: 13))
                  .foregroundColor(Color("Icon"))
              }
              .padding(.leading, 2)
              
              TextField("", text: $searchText, onEditingChanged: { isEdit in
                if !isEdit {
                  isEditSearch = false
                }
              })
              .foregroundColor(Color("UIText").opacity(0.85))
              .padding(.leading, 2)
              .frame(height: 30)
              .textFieldStyle(PlainTextFieldStyle())
              .font(.system(size: 13))
              .fontWeight(.regular)
              .focused($isTextFieldFocused)
            }
          } else {
            HStack(spacing: 0) {
              HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                  .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                  .font(.system(size: 13))
                  .foregroundColor(Color("Icon"))
              }
              .padding(.leading, 2)
              
              Text(searchText)
                .foregroundColor(Color("UIText").opacity(0.85))
                .padding(.leading, 2)
                .frame(height: 30)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .lineLimit(1)
                .truncationMode(.tail)
              
              Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
              isEditSearch = true
              isTextFieldFocused = true
            }
            .onHover { hovering in
              withAnimation(.easeIn(duration: 0.2)) {
                isSearchHover = hovering
              }
            }
          }
        }
        .padding(1)
        .background(isSearchHover ? Color("InputBGHover").opacity(1) : Color("InputBG").opacity(1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
      }
    }
  }
}
