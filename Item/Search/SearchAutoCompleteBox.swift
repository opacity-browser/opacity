//
//  SearchAutoCompleteList.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI

func inputTextWidth(_ text: String) -> CGFloat {
  let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13.5)]
  let attributedString = NSAttributedString(string: text, attributes: attributes)
  let size = attributedString.size()
  return size.width
}

struct SearchAutoCompleteBox: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @ObservedObject var manualUpdate: ManualUpdate
  
  var searchHistoryGroups: [SearchHistoryGroup]
  @Binding var autoCompleteList: [SearchHistoryGroup]
  
  @State var searchInputFocus: Bool = false
  @State var autoCompleteIndex: Int = -1
  @State var autoCompleteText: String = ""
  
  var body: some View {
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
        
        SearchNSTextField(browser: browser, tab: tab, manualUpdate: manualUpdate, isFocused: $searchInputFocus, searchHistoryGroups: searchHistoryGroups, autoCompleteList: $autoCompleteList, autoCompleteIndex: $autoCompleteIndex, autoCompleteText: $autoCompleteText)
          .padding(.leading, 3)
          .frame(height: 37)
          .overlay {
            if autoCompleteList.count > 0 && autoCompleteIndex > -1 {
              let autoCompleteText = autoCompleteList[autoCompleteIndex].searchText.replacingOccurrences(of: tab.inputURL, with: "")
              HStack(spacing: 0) {
                VStack(spacing: 0) {
                  Text("\(autoCompleteText)")
                    .font(.system(size: 13.5))
                }
                .frame(height: 16)
                .background(Color("AccentColor").opacity(0.3))
                .padding(.leading, 5)
                .padding(.leading, inputTextWidth(tab.inputURL))
                Spacer()
              }
            }
          }
          .onKeyPress(.upArrow) {
            print("up key down")
            if autoCompleteIndex > 0 {
              autoCompleteIndex = autoCompleteIndex - 1
            } else {
              autoCompleteIndex = autoCompleteList.count - 1
            }
            return .handled
          }
          .onKeyPress(.downArrow) {
            print("down key down")
            if autoCompleteList.count > autoCompleteIndex + 1 {
              autoCompleteIndex = autoCompleteIndex + 1
            } else {
              autoCompleteIndex = 0
            }
            return .handled
          }
          .onAppear {
            DispatchQueue.main.async {
              searchInputFocus = true
            }
          }
        
//        TextField("", text: $tab.inputURL, onEditingChanged: { isEdit in
//          if !isEdit {
//            tab.isEditSearch = false
//          }
//        })
//        .onAppear {
//          DispatchQueue.main.async {
//            isTextFieldFocused = true
//          }
//        }
//        .offset(y: -0.5)
//        .foregroundColor(Color("UIText").opacity(0.85))
//        .overlay {
//          if autoCompleteList.count > 0 && autoCompleteIndex != -1 {
//            let autoCompleteText = autoCompleteList[autoCompleteIndex].searchText.replacingOccurrences(of: tab.inputURL, with: "")
//            HStack(spacing: 0) {
//              VStack(spacing: 0) {
//                Text("\(autoCompleteText)")
//                  .font(.system(size: 13.5))
//              }
//              .frame(height: 16)
//              .background(Color("AccentColor").opacity(0.3))
//              .padding(.leading, inputTextWidth(tab.inputURL))
//              .offset(y: -0.5)
//              Spacer()
//            }
//          }
//        }
//        .padding(.leading, 7)
//        .frame(height: 37)
//        .textFieldStyle(PlainTextFieldStyle())
//        .font(.system(size: 13.5))
//        .fontWeight(.regular)
//        .focused($isTextFieldFocused)
//        .onKeyPress(.downArrow) {
//          print("down key down")
//          if autoCompleteList.count > autoCompleteIndex + 1 {
//            autoCompleteIndex = autoCompleteIndex + 1
//          } else {
//            autoCompleteIndex = 0
//          }
//          return .handled
//        }
//        .onKeyPress(.upArrow) {
//          print("up key down")
//          if autoCompleteIndex > 0 {
//            autoCompleteIndex = autoCompleteIndex - 1
//          } else {
//            autoCompleteIndex = autoCompleteList.count - 1
//          }
//          return .handled
//        }
//        .onChange(of: tab.inputURL) { oldValue, newValue in
////            if autoCompleteIndex > -1 && oldValue.count > newValue.count {
////              tab.inputURL = oldValue
////              autoCompleteIndex = -1
////              isUpdate = true
////              return
////            }
////
////            if newValue.count > oldValue.count {
////              isUpdate = false
////            }
////
////            if isUpdate {
////              return
////            }
//
//          let lowercaseKeyword = newValue.lowercased()
//          autoCompleteList = searchHistoryGroups.filter {
//            $0.searchText.localizedStandardContains(lowercaseKeyword)
//          }.sorted {
//            $0.searchHistories!.count > $1.searchHistories!.count
//          }.sorted {
//            $0.searchText.lowercased().hasPrefix(lowercaseKeyword) == true && $1.searchText.lowercased().hasPrefix(lowercaseKeyword) == false
//          }.sorted {
//            $0.searchText.hasPrefix(newValue) == true && $1.searchText.hasPrefix(newValue) == false
//          }
//
//          if autoCompleteList.count > 0 && autoCompleteIndex == -1 {
//            autoCompleteIndex = 0
//          }
//        }
//        .onSubmit {
//          if tab.inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            return
//          }
//
//          var newURL = tab.inputURL
//          if StringURL.checkURL(url: newURL) {
//            if !newURL.contains("://") {
//              newURL = "https://\(newURL)"
//            }
//          } else {
//            newURL = "https://www.google.com/search?q=\(newURL)"
//          }
//
//          if(newURL != tab.originURL.absoluteString.removingPercentEncoding) {
//            SearchManager.addSearchHistory(tab.inputURL)
//            manualUpdate.search = !manualUpdate.search
//            DispatchQueue.main.async {
//              tab.isPageProgress = true
//              tab.pageProgress = 0.0
//              tab.updateURLBySearch(url: URL(string: newURL)!)
//              isTextFieldFocused = false
//              tab.isEditSearch = false
//            }
//          }
//        }
      }
      
      if tab.inputURL != "" {
        VStack(spacing: 0) {
          Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 0.5)
            .foregroundColor(Color("UIBorder"))
        }
        .padding(.horizontal, 15)
        
        SearchAutoComplete(tab: tab, autoCompleteList: autoCompleteList)
      }
    }
  }
}
