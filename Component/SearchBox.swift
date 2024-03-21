//
//  SearchBox.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI

struct SearchBox: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @ObservedObject var manualUpdate: ManualUpdate
  
  @State private var isSearchHover: Bool = false
  @State private var isSiteDialog: Bool = false
  @State var isBookmarkHover: Bool = false
  
  let inputHeight: CGFloat = 32
  let textSize: CGFloat = 13.5
  
  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        VStack(spacing: 0) {
          if !tab.isEditSearch {
            HStack(spacing: 0) {
              ZStack {
                ZStack {
                  Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: inputHeight)
                    .foregroundColor(!isBookmarkHover && isSearchHover ? Color("InputBGHover") : Color("InputBG"))
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
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                  
                  HStack(spacing: 0) {
                    Button {
                      self.isSiteDialog.toggle()
                    } label: {
                      HStack(spacing: 0) {
                        Image(systemName: "lock")
                          .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                          .background(Color("SearchBarBG"))
                          .clipShape(RoundedRectangle(cornerRadius: 14))
                          .font(.system(size: 13))
                          .fontWeight(.medium)
                          .foregroundColor(Color("Icon"))
                      }
                      .padding(.leading, 3)
                      .popover(isPresented: $isSiteDialog, arrowEdge: .bottom) {
                        SiteOptionDialog(tab: tab)
                      }
                    }
                    .buttonStyle(.plain)
                    
                    Text(tab.printURL)
                      .frame(minWidth: 175, maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
                      .foregroundColor(Color("UIText").opacity(0.85))
                      .padding(.top, 5)
                      .padding(.bottom, 5)
                      .padding(.leading, 7)
                      .padding(.trailing, 10)
                      .font(.system(size: textSize))
                      .fontWeight(.regular)
                      .opacity(0.9)
                      .lineLimit(1)
                      .truncationMode(.tail)
                    
                    BookmarkIcon(tab: tab, isBookmarkHover: $isBookmarkHover, manualUpdate: manualUpdate)
                      .padding(.trailing, 10)
                  }
                }
                .frame(height: 32)
                .padding(1)
                .background(!isBookmarkHover && isSearchHover ? Color("InputBGHover") : Color("InputBG"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
              }
              .frame(maxWidth: .infinity, maxHeight: inputHeight, alignment: .leading)
              .offset(y: 0.5)
              .onTapGesture {
                DispatchQueue.main.async {
                  tab.isEditSearch = true
                }
              }
              .onHover { hovering in
                withAnimation(.easeIn(duration: 0.2)) {
                  isSearchHover = hovering
                }
              }
            }
            .padding(.leading, 1)
            .padding(.top, 1)
          }
        }
        .onAppear {
          print(geometry.frame(in: .global))
          browser.searchBoxRect = geometry.frame(in: .global)
        }
        .onChange(of: geometry.size) { _, newValue in
          browser.searchBoxRect = geometry.frame(in: .global)
        }
      }
    }
  }
}
  
