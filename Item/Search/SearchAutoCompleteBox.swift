//
//  SearchAutoCompleteList.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

func inputTextWidth(_ text: String) -> CGFloat {
  let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13.5)]
  let attributedString = NSAttributedString(string: text, attributes: attributes)
  let size = attributedString.size()
  return size.width
}

struct SearchAutoCompleteBox: View {
  @Environment(\.colorScheme) var colorScheme
  @Query var generalSettings: [GeneralSetting]
  
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  var searchHistoryGroups: [SearchHistoryGroup]
  var visitHistoryGroups: [VisitHistoryGroup]
  
  @State private var isSiteDialog: Bool = false
  @State var isBookmarkHover: Bool = false
  
  func decodeBase64ToNSImage(base64: String) -> NSImage? {
    guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
      return nil
    }
    
    return NSImage(data: imageData)
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if tab.isEditSearch {
          HStack(spacing: 0) {
            if let settings = generalSettings.first, !StringURL.checkURL(url: tab.inputURL), tab.inputURL != "" {
              let searchEngine = settings.searchEngine
              let searchEngineData = SEARCH_ENGINE_LIST.first(where: { $0.name == searchEngine })
              if let searchEngineFavicon = colorScheme == .dark ? searchEngineData?.faviconWhite : searchEngineData?.favicon, let uiImage = decodeBase64ToNSImage(base64: searchEngineFavicon) {
                VStack(spacing: 0) {
                  Image(nsImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 15, maxHeight: 15)
                    .clipped()
                }
                .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
              } else {
                Image(systemName: "magnifyingglass")
                  .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                  .font(.system(size: 13))
                  .clipShape(RoundedRectangle(cornerRadius: 14))
                  .foregroundColor(Color("Icon"))
              }
            } else {
              Image(systemName: "magnifyingglass")
                .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                .font(.system(size: 13))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .foregroundColor(Color("Icon"))
            }
          }
          .padding(.leading, 7)
        } else {
          Button {
            self.isSiteDialog.toggle()
          } label: {
            HStack(spacing: 0) {
              Image(systemName: "lock")
                .frame(maxWidth: 24, maxHeight: 24, alignment: .center)
                .background(Color("SearchBarBG"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundColor(Color("Icon"))
            }
            .padding(.leading, 4)
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
          SearchNSTextField(browser: browser, tab: tab, searchHistoryGroups: searchHistoryGroups, visitHistoryGroups: visitHistoryGroups)
            .padding(.leading, tab.isEditSearch ? 4 : 9)
            .frame(height: tab.isEditSearch ? 36 : 32)
//            .onChange(of: tab) { _, nV in
//              if !nV.isInit {
//                tab.isBlurBySearchField = true
//                tab.isEditSearch = false
//              }
//            }
            .overlay {
              if let choiceIndex = tab.autoCompleteIndex, tab.isEditSearch, tab.autoCompleteList.count > 0, choiceIndex < tab.autoCompleteList.count {
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
              if (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if choiceIndex > 0 {
                      tab.autoCompleteIndex = choiceIndex - 1
                    } else {
                      tab.autoCompleteIndex = (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) - 1
                    }
                  } else {
                    tab.autoCompleteIndex = (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) - 1
                  }
                  
                  if let choiceIndex = tab.autoCompleteIndex {
                    let targetString = choiceIndex + 1 > tab.autoCompleteList.count
                    ? tab.autoCompleteVisitList[choiceIndex - tab.autoCompleteList.count].url
                    : tab.autoCompleteList[choiceIndex].searchText
                    tab.inputURL = targetString
                  }
                }
                return .handled
              }
              return .ignored
            }
            .onKeyPress(.downArrow) {
              if (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > choiceIndex + 1 {
                      tab.autoCompleteIndex = choiceIndex + 1
                    } else {
                      tab.autoCompleteIndex = 0
                    }
                  } else {
                    tab.autoCompleteIndex = 0
                  }
                  
                  if let choiceIndex = tab.autoCompleteIndex {
                    let targetString = choiceIndex + 1 > tab.autoCompleteList.count
                    ? tab.autoCompleteVisitList[choiceIndex - tab.autoCompleteList.count].url
                    : tab.autoCompleteList[choiceIndex].searchText
                    tab.inputURL = targetString
                  }
                }
                return .handled
              }
              return .ignored
            }
            .onKeyPress(.rightArrow) {
              if let choiceIndex = tab.autoCompleteIndex, (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
                let targetString = choiceIndex + 1 > tab.autoCompleteList.count
                ? tab.autoCompleteVisitList[choiceIndex - tab.autoCompleteList.count].url
                : tab.autoCompleteList[choiceIndex].searchText
                
                if targetString != tab.inputURL {
                  DispatchQueue.main.async {
                    tab.inputURL = targetString
                  }
                }
                return .handled
              }
              return .ignored
            }
        }
          BookmarkIcon(tab: tab, isBookmarkHover: $isBookmarkHover)
            .padding(.leading, 5)
            .padding(.trailing, 10)
      }
      
      if tab.isEditSearch && tab.inputURL != "" && (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
        SearchAutoComplete(browser: browser, tab: tab)
      }
    }
  }
}


extension String {
  func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
    guard let range = self.range(of: string, options: .caseInsensitive) else {
      return self
    }
    return self.replacingCharacters(in: range, with: replacement)
  }
}
