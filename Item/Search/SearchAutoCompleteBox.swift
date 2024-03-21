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
  
  @State var searchInputFocus: Bool = true
  @State var autoCompleteIndex: Int?
  @State var autoCompleteText: String = ""
  
  @State var updateNsViewWindow: Bool = false
  
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
        
        SearchNSTextField(browser: browser, tab: tab, manualUpdate: manualUpdate, isFocused: $searchInputFocus, searchHistoryGroups: searchHistoryGroups, autoCompleteList: $autoCompleteList, autoCompleteIndex: $autoCompleteIndex, autoCompleteText: $autoCompleteText, updateNsViewWindow: $updateNsViewWindow)
          .padding(.leading, 5)
          .frame(height: 37)
          .id(updateNsViewWindow)
          .overlay {
            if let choiceIndex = autoCompleteIndex, autoCompleteList.count > 0 {
              let autoCompleteText = autoCompleteList[choiceIndex].searchText.replacingOccurrences(of: tab.inputURL, with: "")
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
            if autoCompleteList.count > 0 {
              if let choiceIndex = autoCompleteIndex {
                if choiceIndex > 0 {
                  autoCompleteIndex = choiceIndex - 1
                } else {
                  autoCompleteIndex = autoCompleteList.count - 1
                }
              } else {
                autoCompleteIndex = autoCompleteList.count - 1
              }
              DispatchQueue.main.async {
                tab.inputURL = autoCompleteList[autoCompleteIndex!].searchText
              }
              return .handled
            }
            return .ignored
          }
          .onKeyPress(.downArrow) {
            if autoCompleteList.count > 0 {
              if let choiceIndex = autoCompleteIndex {
                if autoCompleteList.count > choiceIndex + 1 {
                  autoCompleteIndex = choiceIndex + 1
                } else {
                  autoCompleteIndex = 0
                }
              } else {
                autoCompleteIndex = 0
              }
              DispatchQueue.main.async {
                tab.inputURL = autoCompleteList[autoCompleteIndex!].searchText
              }
              return .handled
            }
            return .ignored
          }
          .onKeyPress(.rightArrow) {
            if let choiceIndex = autoCompleteIndex, autoCompleteList.count > 0, autoCompleteList[choiceIndex].searchText != tab.inputURL {
              DispatchQueue.main.async {
                tab.inputURL = autoCompleteList[choiceIndex].searchText
              }
              return .handled
            }
            return .ignored
          }
      }
      
      if tab.inputURL != "" && autoCompleteList.count > 0 {
        SearchAutoComplete(browser: browser, tab: tab, autoCompleteList: $autoCompleteList, autoCompleteIndex: $autoCompleteIndex)
      }
    }
  }
}
