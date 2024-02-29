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
  
  @FocusState private var isTextFieldFocused: Bool
  
  @State private var isSearchHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isTopHover: Bool = false
  @State private var isLocaionHover: Bool = false
  @State private var isNotificationHover: Bool = false
  
  @State private var isMoreMenuDialog: Bool = false
  @State private var isSiteDialog: Bool = false
  

  let inputHeight: CGFloat = 32
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  let textSize: CGFloat = 13.5
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 10)
      
      HistoryBackBtn(tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 8)
      
      HistoryForwardBtn(tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 8)
      
      HistoryRefreshBtn(iconHeight: iconHeight, iconRadius: iconRadius)
      
      VStack(spacing: 0) { }.frame(width: 6)
      
      Spacer()
      
      if tab.isEditSearch {
        HStack(spacing: 0) {
          ZStack {
            Rectangle()
              .frame(maxWidth: .infinity, maxHeight: inputHeight)
              .foregroundColor(Color("MainBlack"))
              .clipShape(RoundedRectangle(cornerRadius: 9))
              .padding(0)
            
            HStack(spacing: 0) {
              HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                  .frame(maxWidth: 22, maxHeight: 22, alignment: .center)
                  .font(.system(size: 12))
                  .foregroundColor(Color.white.opacity(0.9))
              }
              .padding(.top, 1)
              .padding(.leading, 4)
              
              TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
                if !isEdit {
                  tab.isEditSearch = false
                }
              })
              .foregroundColor(.white.opacity(0.85))
              .padding(.leading, 5)
              .frame(maxHeight: inputHeight)
              .textFieldStyle(PlainTextFieldStyle())
              .font(.system(size: textSize))
              .fontWeight(.regular)
              .focused($isTextFieldFocused)
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
                
                if(newURL != tab.originURL.absoluteString) {
                  DispatchQueue.main.async {
                    tab.isPageProgress = true
                    tab.pageProgress = 0.0
                    tab.updateURLBySearch(url: URL(string: newURL)!)
                    tab.isEditSearch = false
                    isTextFieldFocused = false
                  }
                }
              }
            }
          }
          .padding(1)
          .background(Color("Point"))
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
                  if !tab.isInit && tab.isPageProgress {
                    HStack(spacing: 0) {
                      Rectangle()
                        .foregroundColor(Color("Point"))
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
                Button {
                  self.isSiteDialog.toggle()
                } label: {
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
                  .popover(isPresented: $isSiteDialog, arrowEdge: .bottom) {
                    SiteOptionDialog(tab: tab)
                  }
                }
                .buttonStyle(.plain)
                
                Text(tab.printURL)
                  .frame(minWidth: 200, maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
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
              tab.isEditSearch = true
              isTextFieldFocused = true
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
      
      if tab.isNotificationDialogIcon {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "bell.slash")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isNotificationHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onHover { inside in
            withAnimation {
              isNotificationHover = inside
            }
          }
          .onTapGesture {
            tab.isNotificationDetailDialog.toggle()
          }
          .popover(isPresented: $tab.isNotificationDetailDialog, arrowEdge: .bottom) {
            NotificationDialog(tab: tab)
          }
        }
        .padding(.trailing, 8)
      }
      
      if tab.isLocationDialogIcon {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "location.slash")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isLocaionHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onHover { inside in
            withAnimation {
              isLocaionHover = inside
            }
          }
          .onTapGesture {
            tab.isLocationDetailDialog.toggle()
          }
          .popover(isPresented: $tab.isLocationDetailDialog, arrowEdge: .bottom) {
            GeoLocationDialog()
          }
        }
        .padding(.trailing, 8)
      }
      
//      VStack(spacing: 0) {
//        VStack(spacing: 0) {
//          Image(systemName: "arrow.up.to.line.compact")
//            .foregroundColor(Color("Icon"))
//            .font(.system(size: 14))
//            .fontWeight(.regular)
//            .offset(y: 1)
//        }
//        .frame(maxWidth: iconHeight, maxHeight: iconHeight)
//        .background(isTopHover ? .gray.opacity(0.2) : .gray.opacity(0))
//        .clipShape(RoundedRectangle(cornerRadius: iconRadius))
//        .onHover { hovering in
//          withAnimation {
//            isTopHover = hovering
//          }
//        }
//        .onTapGesture {
//          tab.webview.evaluateJavaScript("window.scrollTo(0, 0)")
//        }
//      }
//      .padding(.trailing, 8)
      
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
        .onTapGesture {
          self.isMoreMenuDialog.toggle()
        }
        .popover(isPresented: $isMoreMenuDialog, arrowEdge: .bottom) {

        }
      }
      .padding(.trailing, 10)
      .onChange(of: tab.isEditSearch) { _, newValue in
        if(tab.isInit && !isTextFieldFocused) {
          isTextFieldFocused = true
        }
      }
    }
    .frame(height: 32)
    .offset(y: -2.5)
  }
}

