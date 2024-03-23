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
  
  @State private var isSiteDialog: Bool = false
  @State var isBookmarkHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if tab.isEditSearch {
          HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
              .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
              .font(.system(size: 13))
              .clipShape(RoundedRectangle(cornerRadius: 14))
              .foregroundColor(Color("Icon"))
          }
          .padding(.leading, 7)
        } else {
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
        }
        
        ZStack {
          if !tab.isEditSearch {
            HStack(spacing: 0) {
              Text(tab.printURL)
                .font(.system(size: 13.5))
                .padding(.leading, 9)
                .frame(height: 32)
                .lineLimit(1)
                .truncationMode(.tail)
              Spacer()
            }
          }
          SearchNSTextField(browser: browser, tab: tab, manualUpdate: manualUpdate, searchHistoryGroups: searchHistoryGroups)
            .padding(.leading, tab.isEditSearch ? 5 : 9)
            .frame(height: tab.isEditSearch ? 37 : 32)
            .overlay {
              if let choiceIndex = tab.autoCompleteIndex, tab.isEditSearch, tab.autoCompleteList.count > 0 {
                let autoCompleteText = tab.autoCompleteList[choiceIndex].searchText.replacingFirstOccurrence(of: tab.inputURL, with: "")
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
              if tab.autoCompleteList.count > 0 {
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if choiceIndex > 0 {
                      tab.autoCompleteIndex = choiceIndex - 1
                    } else {
                      tab.autoCompleteIndex = tab.autoCompleteList.count - 1
                    }
                  } else {
                    tab.autoCompleteIndex = tab.autoCompleteList.count - 1
                  }
                  tab.inputURL = tab.autoCompleteList[tab.autoCompleteIndex!].searchText
                }
                return .handled
              }
              return .ignored
            }
            .onKeyPress(.downArrow) {
              if tab.autoCompleteList.count > 0 {
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if tab.autoCompleteList.count > choiceIndex + 1 {
                      tab.autoCompleteIndex = choiceIndex + 1
                    } else {
                      tab.autoCompleteIndex = 0
                    }
                  } else {
                    tab.autoCompleteIndex = 0
                  }
                  tab.inputURL = tab.autoCompleteList[tab.autoCompleteIndex!].searchText
                }
                return .handled
              }
              return .ignored
            }
            .onKeyPress(.rightArrow) {
              if let choiceIndex = tab.autoCompleteIndex, tab.autoCompleteList.count > 0, tab.autoCompleteList[choiceIndex].searchText != tab.inputURL {
                DispatchQueue.main.async {
                  tab.inputURL = tab.autoCompleteList[choiceIndex].searchText
                }
                return .handled
              }
              return .ignored
            }
        }
          BookmarkIcon(tab: tab, isBookmarkHover: $isBookmarkHover, manualUpdate: manualUpdate)
            .padding(.leading, 5)
            .padding(.trailing, 10)
      }
      
      if tab.isEditSearch && tab.inputURL != "" && tab.autoCompleteList.count > 0 {
        SearchAutoComplete(browser: browser, tab: tab)
      }
    }
  }
}


extension String {
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else {
            return self
        }
        return self.replacingCharacters(in: range, with: replacement)
    }
}
