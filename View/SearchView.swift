//
//  TitleView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var tab: Tab
  
  @FocusState private var textFieldFocused: Bool
  @State private var isEditing: Bool = false
  @State private var isSearchHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isRefreshHober: Bool = false
  
  let inputHeight: Double = 29
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      Image(systemName: "chevron.backward")
        .padding(.leading, 5)
        .padding(.trailing, 12)
        .foregroundColor(.gray.opacity(0.7))
        .font(.system(size: 14))
        .onTapGesture {
          tab.goBack = true
        }
      
      Image(systemName: "chevron.forward")
        .padding(.leading, 10)
        .padding(.trailing, 11)
        .foregroundColor(.gray.opacity(0.7))
        .font(.system(size: 14))
        .onTapGesture {
          tab.goForward = true
        }
      
      Image(systemName: "goforward")
        .padding(.leading, 14)
        .padding(.trailing, 14)
        .foregroundColor(.gray.opacity(0.7))
        .font(.system(size: 13.5))
        .onTapGesture {
//          tab.goForward = true
        }
      
      Spacer()
      
      if isEditing {
        HStack(spacing: 0) {
          TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
            if !isEdit {
              isEditing = false
            }
          })
          .frame(maxHeight: inputHeight)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.system(size: 13))
          .fontWeight(.regular)
          .padding(.top, 4)
          .padding(.bottom, 4)
          .padding(.leading, 19)
          .padding(.trailing, 34)
          .background(colorScheme == .dark ? Color("MainBlack") : .white)
//          .foregroundColor(colorScheme == .dark ? .white : .black)
          .focused($textFieldFocused)
          .onSubmit {
            var uriString = tab.inputURL
            if !uriString.contains("://") {
              uriString = "https://\(uriString)"
            }
            
            tab.webURL = uriString
            tab.goToPage = true
          }
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(1)
        .background(Color("PointColor"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
      } else {
        HStack {
          Text(tab.viewURL)
//              .frame(maxWidth: 300, alignment: .leading)
            .frame(maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 35)
            .font(.system(size: 13))
            .fontWeight(.regular)
            .opacity(0.7)
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .frame(alignment: .leading)
        .background(isSearchHover ? .gray.opacity(0.2) : .gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
//          withAnimation {
            isEditing = true
            textFieldFocused = true
//          }
        }
        .onHover { hovering in
          withAnimation {
            isSearchHover = hovering
          }
        }
      }
      
      Spacer()
      
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "ellipsis")
            .font(.system(size: 14))
            .rotationEffect(.degrees(90))
            .opacity(0.7)
        }
        .frame(maxWidth: 24, maxHeight: 24)
        .background(isMoreHover ? .gray.opacity(0.1) : .gray.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onHover { hovering in
          withAnimation {
            isMoreHover = hovering
          }
        }
      }
      .padding(.leading, 5)
      .padding(.trailing, 10)
      
//      VStack{ }.frame(maxWidth: 10)
    }
    .frame(height: 29)
//    .background(.red.opacity(0.2))
    .offset(y: -2)
  }
}
