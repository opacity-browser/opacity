//
//  SearchAutoCompleteList.swift
//  Opacity
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchAutoCompleteBox: View {
  @Environment(\.colorScheme) var colorScheme
  @Query var generalSettings: [GeneralSetting]
  
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @Query(sort: \SearchHistoryGroup.updateDate, order: .reverse)
  var searchHistoryGroups: [SearchHistoryGroup]
  @Query(sort: \VisitHistoryGroup.updateDate, order: .reverse)
  var visitHistoryGroups: [VisitHistoryGroup]
  
  var tabWidth: CGFloat
  
  @State private var isSiteDialog: Bool = false
  @State var isScrollable: Bool = false
  
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
              if tab.originURL.scheme == "opacity" || tab.isValidCertificate == true {
                Image(systemName: "lock.fill")
                  .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                  .clipShape(RoundedRectangle(cornerRadius: 14))
                  .font(.system(size: 13))
                  .fontWeight(.medium)
                  .foregroundColor(Color("Icon"))
              } else if tab.isValidCertificate == false {
                Image(systemName: "exclamationmark.triangle.fill")
                  .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                  .clipShape(RoundedRectangle(cornerRadius: 14))
                  .font(.system(size: 13))
                  .fontWeight(.medium)
                  .foregroundColor(Color("AlertText"))
              } else {
                Image(systemName: "lock.fill")
                  .frame(maxWidth: 26, maxHeight: 26, alignment: .center)
                  .clipShape(RoundedRectangle(cornerRadius: 14))
                  .font(.system(size: 13))
                  .fontWeight(.medium)
                  .foregroundColor(Color("Icon"))
                  .opacity(0.5)
              }
            }
            .background(Color("InputBG"))
            .popover(isPresented: $isSiteDialog, arrowEdge: .bottom) {
              SiteOptionDialog(service: service, browser: browser, tab: tab, isSiteDialog: $isSiteDialog)
            }
          }
          .padding(.leading, 7)
          .buttonStyle(.plain)
        }
        
        ZStack {
          if !tab.isEditSearch {
            HStack(spacing: 0) {
              HStack {
                SearchNSTextView(text: tab.printURL, opacity: 0.7)
                  .clipped()
              }
              .frame(height: 17)
            }
            .padding(.leading, 4)
          } else {
            if let choiceIndex = tab.autoCompleteIndex, tab.isEditSearch, tab.autoCompleteList.count > 0, choiceIndex < tab.autoCompleteList.count {
              HStack(spacing: 0) {
                HStack(spacing: 0) {
                  SearchNSTextView(text: searchBackgroundText(choiceIndex), opacity: 0.35)
                }
                .frame(height: 17)
              }
              .padding(.leading, 4)
            }
          }
          
          SearchNSTextField(browser: browser, tab: tab, searchHistoryGroups: searchHistoryGroups, visitHistoryGroups: visitHistoryGroups, isScrollable: $isScrollable)
            .padding(.leading, tab.isEditSearch ? 4 : 9)
            .padding(.leading, isScrollable ? 0.2 : 0)
            .frame(height: tab.isEditSearch ? 36 : 32)
            .onKeyPress(.upArrow) {
              if (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
                let maxSearchCount = tab.autoCompleteList.count > 5 ? 5 : tab.autoCompleteList.count
                let maxVisitCount = tab.autoCompleteVisitList.count > 5 ? 5 : tab.autoCompleteVisitList.count
                let maxCount = maxSearchCount + maxVisitCount
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if choiceIndex > 0 {
                      tab.autoCompleteIndex = choiceIndex - 1
                    } else {
                      tab.autoCompleteIndex = maxCount - 1
                    }
                  } else {
                    tab.autoCompleteIndex = maxCount - 1
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
                let maxSearchCount = tab.autoCompleteList.count > 5 ? 5 : tab.autoCompleteList.count
                let maxVisitCount = tab.autoCompleteVisitList.count > 5 ? 5 : tab.autoCompleteVisitList.count
                let maxCount = maxSearchCount + maxVisitCount
                DispatchQueue.main.async {
                  tab.isChangeByKeyDown = true
                  if let choiceIndex = tab.autoCompleteIndex {
                    if maxCount > choiceIndex + 1 {
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
                  return .handled
                }
              }
              return .ignored
            }
            .onKeyPress(.tab) {
              if let choiceIndex = tab.autoCompleteIndex, (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
                let targetString = choiceIndex + 1 > tab.autoCompleteList.count
                ? tab.autoCompleteVisitList[choiceIndex - tab.autoCompleteList.count].url
                : tab.autoCompleteList[choiceIndex].searchText
                
                if targetString != tab.inputURL {
                  DispatchQueue.main.async {
                    tab.inputURL = targetString
                  }
                  return .handled
                }
              }
              return .ignored
            }
        }
        
        if tab.isLocationDialogIconByHost {
          LocationPermissionIcon(tab: tab)
            .padding(.horizontal, 2)
        }
        
        BookmarkIcon(tab: tab)
          .padding(.leading, 5)
          .padding(.trailing, 10)
      }
      if tab.isEditSearch && tab.inputURL != "" && (tab.autoCompleteList.count + tab.autoCompleteVisitList.count) > 0 {
        SearchAutoComplete(browser: browser, tab: tab)
      }
    }
  }
  
  func searchBackgroundText(_ choiceIndex: Int) -> String {
    var printText = tab.autoCompleteList[choiceIndex].searchText
    for (index, char) in tab.inputURL.enumerated() {
      guard index < printText.count else { break }
      let resultIndex = printText.index(printText.startIndex, offsetBy: index)
      printText.replaceSubrange(resultIndex...resultIndex, with: String(char))
    }
    return printText
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
