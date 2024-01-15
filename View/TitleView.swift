//
//  TitleView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct TitleView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var viewSize: CGSize
//  @Binding var tab: Tab
//  @Binding var webURL: String
//  @Binding var inputURL: String
//  @Binding var viewURL: String
//  @Binding var goBack: Bool
//  @Binding var goForward: Bool
//  @Binding var goToPage: Bool
  
  @Binding var tab: Tab
//  @Binding var activeTabIndex: Int
  
  
  @FocusState private var textFieldFocused: Bool
  @State private var isEditing: Bool = false
  @State private var isSearchHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isRefreshHober: Bool = false
  @State private var isTitleMargin: Double = 0
  
  var body: some View {
    HStack {
      GeometryReader { geometry in
        HStack {
          VStack { }.frame(width: isTitleMargin)
          
          Spacer()
          
          Image(systemName: "chevron.backward")
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .foregroundColor(.gray.opacity(0.7))
            .font(.system(size: 14))
            .onTapGesture {
              tab.goBack = true
            }
          
          Image(systemName: "chevron.forward")
            .padding(.leading, 5)
            .padding(.trailing, 10)
            .foregroundColor(.gray.opacity(0.7))
            .font(.system(size: 14))
            .onTapGesture {
              tab.goForward = true
            }
          
          if isEditing {
            ZStack(alignment: .trailing) {
              TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
                if !isEdit {
                  isEditing = false
                }
              })
              .focused($textFieldFocused)
              .onSubmit {
                var uriString = tab.inputURL
                if !uriString.contains("://") {
                  uriString = "https://\(uriString)"
                }
                
                tab.webURL = uriString
                tab.goToPage = true
              }
              .textFieldStyle(PlainTextFieldStyle())
              .padding(.top, 4)
              .padding(.bottom, 4)
              .padding(.leading, 19)
              .padding(.trailing, 35)
              .background(colorScheme == .dark ? .gray.opacity(0.2) : .white)
              .clipShape(RoundedRectangle(cornerRadius: 6))
              .font(.system(size: 12))
              .fontWeight(.regular)
              Image(systemName: "goforward")
                .padding(.top, 1)
                .padding(.leading, 5)
                .padding(.trailing, 9)
                .foregroundColor(isRefreshHober ? .black.opacity(0.7) : .gray.opacity(0.7))
                .font(.system(size: 14))
                .rotationEffect(.degrees(45))
                .onTapGesture {
                  isEditing = false
                  textFieldFocused = false
                  print("action webview refresh")
                }
                .onHover { hovering in
                  isRefreshHober = hovering
                }
            }
            .padding(1)
            .background(.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .frame(maxWidth: 300)
          } else {
            HStack {
              Text(tab.viewURL)
                .frame(maxWidth: 300, alignment: .leading)
                .padding(.top, 5)
                .padding(.bottom, 5)
                .padding(.leading, 20)
                .padding(.trailing, 5)
                .font(.system(size: 12))
                .fontWeight(.regular)
                .opacity(0.7)
                .lineLimit(1)
                .truncationMode(.tail)
              Image(systemName: "goforward")
                .padding(.top, 1)
                .padding(.leading, 5)
                .padding(.trailing, 10)
              //              .foregroundColor(isRefreshHober ? .black.opacity(0.7) : .gray.opacity(0.7))
                .opacity(isRefreshHober ? 0.7 : 0.4)
                .font(.system(size: 14))
                .rotationEffect(.degrees(45))
                .onTapGesture {
                  isEditing = false
                  textFieldFocused = false
                  print("action webview refresh")
                }
                .onHover { hovering in
                  isRefreshHober = hovering
                }
            }
            .frame(maxWidth: 300, alignment: .leading)
            .background(isSearchHover ? .gray.opacity(0.2) : .gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .onTapGesture {
              withAnimation {
                isEditing = true
                textFieldFocused = true
              }
            }
            .onHover { hovering in
              withAnimation {
                isSearchHover = hovering
              }
            }
          }
          
          Spacer()
          
          VStack {
            Image(systemName: "ellipsis")
            //            .foregroundColor(.black.opacity(0.7))
              .font(.system(size: 14))
              .rotationEffect(.degrees(90))
              .opacity(0.7)
          }
          .padding(.leading, 5)
          .padding(.trailing, 5)
          .frame(maxWidth: 24, maxHeight: 24)
          .background(isMoreHover ? .gray.opacity(0.1) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { hovering in
            withAnimation {
              isMoreHover = hovering
            }
          }
          
          VStack{ }.frame(maxWidth: 0)
        }
        .frame(height: 38)
        .onChange(of: geometry.size, { oldValue, newValue in
          DispatchQueue.main.async {
            let isActionPeriod = viewSize.width - geometry.size.width <= 140
            
            if viewSize.width - oldValue.width == 0 && viewSize.width - newValue.width > 0 {
              isTitleMargin = 0
            } else if isActionPeriod && viewSize.width < 620 {
              isTitleMargin = 620 - viewSize.width
            } else {
              isTitleMargin = 0
            }
          }
        })
      }
    }
  }
}
