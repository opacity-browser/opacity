//
//  SearchBoxDialog.swift
//  Opacity
//
//  Created by Falsy on 3/16/24.
//

import SwiftUI

struct SearchBoxDialog: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @FocusState private var isTextFieldFocused: Bool
  
  var body: some View {
    if let searchBoxRect = browser.searchBoxRect, tab.isEditSearch {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          HStack(spacing: 0) {
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                HStack(spacing: 0) {
                  Image(systemName: "magnifyingglass")
                    .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                    .font(.system(size: 13))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .foregroundColor(Color("Icon"))
                }
                .padding(.leading, 9)
                .offset(y: -1)
                
                TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
                  if !isEdit {
                    tab.isEditSearch = false
                  }
                })
                .offset(y: -1.5)
                .foregroundColor(Color("UIText").opacity(0.85))
                .padding(.leading, 7)
                .frame(height: 44)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 13.5))
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
                  
                  if(newURL != tab.originURL.absoluteString.removingPercentEncoding) {
                    SearchManager.addSearchHistory(tab.inputURL)
                    DispatchQueue.main.async {
                      tab.isPageProgress = true
                      tab.pageProgress = 0.0
                      tab.updateURLBySearch(url: URL(string: newURL)!)
                      isTextFieldFocused = false
                      tab.isEditSearch = false
                    }
                  }
                }
              }
              
              Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 0.5)
                .foregroundColor(Color("UIBorder"))
                .offset(y: -1)
              
              VStack(spacing: 0) {
                Text("search-list-1")
                Text("search-list-2")
                Text("search-list-3")
              }
            }
            .frame(width: searchBoxRect.width + 8)
            .background(Color("SearchBarBG"))
          }
          .background(Color("SearchBarBG"))
          .clipShape(RoundedRectangle(cornerRadius: 15))
          .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
          .overlay(
            RoundedRectangle(cornerRadius: 15)
              .stroke(Color("UIBorder"), lineWidth: 1)
          )
          Spacer()
        }
        Spacer()
      }
      .padding(.top, 3)
      .padding(.leading, searchBoxRect.minX - 4)
      .onAppear {
        isTextFieldFocused = true
      }
    }
  }
}
