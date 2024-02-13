//
//  TitleView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var tab: Tab
  @Binding var showProgress: Bool
  
  @FocusState private var textFieldFocused: Bool
  
  @State private var isEditing: Bool = false
  @State private var isSearchHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isBackHover: Bool = false
  @State private var isForwardHober: Bool = false
  @State private var isRefreshHober: Bool = false
  
  let inputHeight: Double = 32
  let iconHeight: Double = 24
  let iconRadius: Double = 6
  let textSize: Double = 13.5
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 10)
      
      VStack(spacing: 0) {
        Image(systemName: "chevron.backward")
          .foregroundColor(Color("Icon"))
          .fontWeight(.regular)
          .font(.system(size: 14))
          .opacity(tab.isBack ? 1 : 0.4)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isBackHover && tab.isBack ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isBackHover = hovering
        }
      }
      .onTapGesture {
        if tab.isBack {
          tab.webview.goBack()
        }
      }
      
      VStack(spacing: 0) { }.frame(width: 8)
      
      VStack(spacing: 0) {
        Image(systemName: "chevron.forward")
          .foregroundColor(Color("Icon"))
          .fontWeight(.regular)
          .font(.system(size: 14))
          .opacity(tab.isForward ? 1 : 0.4)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isForwardHober && tab.isForward ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isForwardHober = hovering
        }
      }
      .onTapGesture {
        if tab.isForward {
          tab.webview.goForward()
        }
      }
      
      VStack(spacing: 0) { }.frame(width: 8)
      
      VStack(spacing: 0) {
        Image(systemName: "goforward")
          .rotationEffect(.degrees(45))
          .foregroundColor(Color("Icon"))
          .font(.system(size: 13.5))
          .fontWeight(.regular)
      }
      .frame(maxWidth: iconHeight, maxHeight: iconHeight)
      .background(isRefreshHober ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: iconRadius))
      .onHover { hovering in
        withAnimation {
          isRefreshHober = hovering
        }
      }
      .onTapGesture {
        tab.webview.reload()
      }
      
      VStack(spacing: 0) { }.frame(width: 6)
      
      Spacer()
      
      if isEditing {
        HStack(spacing: 0) {
          ZStack {
            Rectangle()
              .frame(maxWidth: .infinity, maxHeight: inputHeight)
              .foregroundColor(Color("MainBlack"))
              .clipShape(RoundedRectangle(cornerRadius: 9))
              .padding(0)
//              .offset(y: 1)
            
            HStack(spacing: 0) {
              HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                  .frame(maxWidth: 22, maxHeight: 22, alignment: .center)
//                  .background(Color("MainBlack"))
//                  .clipShape(RoundedRectangle(cornerRadius: 11))
                  .font(.system(size: 12))
                  .foregroundColor(Color.white.opacity(0.9))
              }
              .padding(.top, 1)
              .padding(.leading, 4)
              
              TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
                if !isEdit {
                  isEditing = false
                }
              })
              .foregroundColor(.white.opacity(0.85))
              .padding(.leading, 5)
              .frame(maxHeight: inputHeight)
              .textFieldStyle(PlainTextFieldStyle())
              .font(.system(size: textSize))
              .fontWeight(.regular)
              .focused($textFieldFocused)
//              .onChange(of: tab.inputURL) {
//                self.isDomain = StringURL.checkURL(url: tab.inputURL)
//              }
              .onSubmit {
                if tab.inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                  return
                }
                var newURL = tab.inputURL
                if StringURL.checkURL(url: newURL) {
                  if !newURL.contains("://") {
                    newURL = "https://\(newURL)"
                  }
                } else {
                  newURL = "https://www.google.com/search?q=\(newURL)"
                }

                showProgress = true
                tab.pageProgress = 0.0
                DispatchQueue.main.async {
                  tab.updateURLBySearch(url: URL(string: newURL)!)
                }
              }
            }
          }
          .padding(2)
          .background(Color("PointJade"))
          .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 1)
        .padding(.leading, 1)
      } else {
        HStack(spacing: 0) {
          GeometryReader { geometry in
            ZStack {
              Rectangle()
                .frame(maxWidth: .infinity, maxHeight: inputHeight)
                .foregroundColor(isSearchHover ? .gray.opacity(0.3) : .gray.opacity(0.15))
                .overlay {
                  if showProgress {
                    HStack(spacing: 0) {
                      Rectangle()
                        .foregroundColor(Color("PointJade"))
                        .frame(maxWidth: geometry.size.width * CGFloat(tab.pageProgress), maxHeight: 2, alignment: .leading)
                        .animation(.linear(duration: 0.5), value: tab.pageProgress)
                      if tab.pageProgress < 1.0 {
                        Spacer()
                      }
                    }
                    .frame(maxWidth: .infinity, maxHeight: inputHeight, alignment: .bottom)
                  }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
              
              HStack(spacing: 0) {
                HStack(spacing: 0) {
                  Image(systemName: "lock.shield")
                    .frame(maxWidth: 22, maxHeight: 22, alignment: .center)
                    .background(Color("MainBlack"))
                    .clipShape(RoundedRectangle(cornerRadius: 11))
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.9))
                }
                .padding(.leading, 5)
                .padding(.top, 1)
                
                Text(tab.printURL)
                  .frame(maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
                  .foregroundColor(.white.opacity(0.85))
                  .padding(.top, 5)
                  .padding(.bottom, 5)
                  .padding(.leading, 5)
                  .padding(.trailing, 10)
                  .font(.system(size: textSize))
                  .fontWeight(.regular)
                  .opacity(0.9)
                  .lineLimit(1)
                  .truncationMode(.tail)
              }
            }
            .frame(maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
            .onTapGesture {
              isEditing = true
              textFieldFocused = true
            }
            .onHover { hovering in
              withAnimation {
                isSearchHover = hovering
              }
            }
          }
        }
        .padding(.leading, 1)
        .padding(.top, 1)
      }
      
      Spacer()
      
      VStack(spacing: 0) { }.frame(width: 6)
      
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "ellipsis")
            .rotationEffect(.degrees(90))
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
        }
        .frame(maxWidth: iconHeight, maxHeight: iconHeight)
        .background(isMoreHover ? .gray.opacity(0.2) : .gray.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: iconRadius))
        .onHover { hovering in
          withAnimation {
            isMoreHover = hovering
          }
        }
      }
      .padding(.trailing, 10)
      
//      VStack{ }.frame(maxWidth: 10)
    }
    .frame(height: 32)
//    .background(.red.opacity(0.2))
    .offset(y: -1.5)
  }
}
