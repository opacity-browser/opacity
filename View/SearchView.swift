//
//  TitleView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var tabs: [Tab]
  @Binding var activeTabIndex: Int
  
  @FocusState private var textFieldFocused: Bool
  @State private var isEditing: Bool = false
  @State private var isSearchHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isRefreshHober: Bool = false
  
  let inputHeight: Double = 28
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      Image(systemName: "chevron.backward")
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .foregroundColor(Color("Icon"))
        .font(.system(size: 14))
        .fontWeight(.regular)
        .onTapGesture {
          if let webview = tabs[activeTabIndex].webview {
            webview.goBack()
          }
        }
      
      Image(systemName: "chevron.forward")
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .foregroundColor(Color("Icon"))
        .fontWeight(.regular)
        .font(.system(size: 14))
        .onTapGesture {
          if let webview = tabs[activeTabIndex].webview {
            webview.goForward()
          }
        }
      
      Image(systemName: "goforward")
        .padding(.leading, 14)
        .padding(.trailing, 14)
        .foregroundColor(Color("Icon"))
        .font(.system(size: 13.5))
        .fontWeight(.regular)
        .onTapGesture {
          if let webview = tabs[activeTabIndex].webview {
            webview.reload()
          }
        }
      
      Spacer()
      
      if isEditing {
        HStack(spacing: 0) {
          TextField("", text: $tabs[activeTabIndex].inputURL, onEditingChanged: { isEdit in
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
            var uriString = tabs[activeTabIndex].inputURL
            if !uriString.contains("://") {
              uriString = "https://\(uriString)"
            }
            
            tabs[activeTabIndex].webURL = uriString
            tabs[activeTabIndex].goToPage = true
          }
          .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(1)
        .background(Color("PointColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
      } else if tabs.count > 0 {
        HStack {
          Text(tabs[activeTabIndex].viewURL)
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
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
            .rotationEffect(.degrees(90))
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
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
    .frame(height: 28)
//    .background(.red.opacity(0.2))
    .offset(y: -1.5)
  }
}
