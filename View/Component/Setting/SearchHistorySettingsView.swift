//
//  SearchHistorySettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct SearchHistorySettingsView: View {
  @Query(sort: \SearchHistory.createDate, order: .reverse) var searchHistories: [SearchHistory]
  @State private var showingClearAlert = false
  @State private var displayCount = 30
  @State private var searchKeyword = ""
  @ObservedObject var browser: Browser
  
  init(browser: Browser) {
    self.browser = browser
  }
  
  var filteredHistories: [SearchHistory] {
    if searchKeyword.isEmpty {
      return searchHistories
    } else {
      return searchHistories.filter { history in
        history.searchHistoryGroup?.searchText.localizedCaseInsensitiveContains(searchKeyword) ?? false
      }
    }
  }
  
  var groupedHistories: [(date: Date, histories: [SearchHistory])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: filteredHistories.prefix(displayCount)) { history in
      calendar.startOfDay(for: history.createDate)
    }
    return grouped.sorted { $0.key > $1.key }.map { (date: $0.key, histories: $0.value) }
  }
  
  var body: some View {
    VStack(spacing: 32) {
      HStack(spacing: 0) {
        Text(NSLocalizedString("Search History", comment: ""))
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
        
        Spacer()
        
        Button(NSLocalizedString("Clear All", comment: "")) {
          showingClearAlert = true
        }
        .buttonStyle(SettingsActionButtonStyle())
      }
      
      HStack {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 14))
          .foregroundColor(Color("Icon").opacity(0.8))
          .padding(.trailing, 4)
        
        TextField(NSLocalizedString("Search", comment: ""), text: $searchKeyword)
          .textFieldStyle(.plain)
          .font(.system(size: 14))
          .foregroundColor(Color("UIText"))
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 14)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color("InputBG").opacity(0.5))
      )
      
      if filteredHistories.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 48))
            .foregroundColor(Color("Icon").opacity(0.3))
          
          Text(searchKeyword.isEmpty ? 
                NSLocalizedString("There is no search history.", comment: "") :
                NSLocalizedString("No results found.", comment: ""))
            .font(.system(size: 16))
            .foregroundColor(Color("UIText").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
      } else {
        VStack(spacing: 16) {
          ForEach(Array(groupedHistories.enumerated()), id: \.offset) { index, group in
            VStack(alignment: .leading, spacing: 8) {
              Text(formatDateHeader(group.date))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("UIText").opacity(0.6))
                .padding(.horizontal, 16)
              
              ForEach(group.histories, id: \.id) { history in
                if history.searchHistoryGroup?.searchText != nil {
                  SearchHistoryRow(searchHistory: history, browser: browser)
                }
              }
            }
          }
          
          if filteredHistories.count > displayCount {
            HStack {
              Spacer()
              Button(action: {
                displayCount += 30
              }) {
                HStack(spacing: 8) {
                  Image(systemName: "plus.circle")
                    .font(.system(size: 14))
                  Text(NSLocalizedString("Load More", comment: ""))
                    .font(.system(size: 14))
                }
                .foregroundColor(Color("ButtonText"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .padding(.trailing, 4)
                .background(Color("ButtonBG"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
              }
              .buttonStyle(PlainButtonStyle())
              Spacer()
            }
            .padding(.top, 8)
          }
        }
        .padding(.bottom, 20)
      }
    }
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .alert(NSLocalizedString("Clear All", comment: ""), isPresented: $showingClearAlert) {
      Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
      Button(NSLocalizedString("Delete", comment: ""), role: .destructive) {
        SearchManager.deleteAllSearchHistory()
      }
    } message: {
      Text(NSLocalizedString("Are you sure you want to clear all search history?", comment: ""))
    }
  }
  
  private func formatDateHeader(_ date: Date) -> String {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    if calendar.isDateInToday(date) {
      return NSLocalizedString("Today", comment: "")
    } else if calendar.isDateInYesterday(date) {
      return NSLocalizedString("Yesterday", comment: "")
    } else {
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      formatter.locale = Locale.current
      return formatter.string(from: date)
    }
  }
}

struct SearchHistoryRow: View {
  let searchHistory: SearchHistory
  let browser: Browser
  @State private var isHovering = false
  @State private var isHoveringDelete = false
  @Environment(\.modelContext) private var modelContext
  
  var searchText: String {
    searchHistory.searchHistoryGroup?.searchText ?? ""
  }
  
  var date: Date {
    searchHistory.createDate
  }
  
  var body: some View {
    Button(action: {
      performSearch()
    }) {
      HStack(spacing: 0) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 14))
          .foregroundColor(Color("Icon"))
          .frame(width: 20, height: 20)
        
        Text(searchText)
          .font(.system(size: 14))
          .foregroundColor(Color("UIText"))
          .lineLimit(1)
          .padding(.leading, 12)
        
        Spacer()
        
        Text(formatTime(date))
          .font(.system(size: 12))
          .foregroundColor(Color("UIText").opacity(0.6))
          .padding(.trailing, 12)
        
        if isHovering {
          Button(action: {
            deleteSearchHistory()
          }) {
            Image(systemName: "xmark")
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(Color("UIText").opacity(0.6))
              .frame(width: 20, height: 20)
              .background(
                Circle()
                  .fill(Color("UIText").opacity(isHoveringDelete ? 0.15 : 0))
              )
          }
          .buttonStyle(PlainButtonStyle())
          .onHover { hovering in
            isHoveringDelete = hovering
          }
          .onTapGesture {
            deleteSearchHistory()
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color("InputBG").opacity(isHovering ? 0.6 : 0.4))
      )
    }
    .buttonStyle(PlainButtonStyle())
    .onHover { hovering in
      isHovering = hovering
    }
  }
  
  private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale.current
    return formatter.string(from: date)
  }
  
  private func deleteSearchHistory() {
    modelContext.delete(searchHistory)
    try? modelContext.save()
  }
  
  private func performSearch() {
    // 설정된 검색 엔진을 사용하여 새 탭에서 검색
    Task { @MainActor in
      if let activeTab = browser.tabs.first(where: { $0.id == browser.activeTabId }) {
        let searchURLString = activeTab.changeKeywordToURL(searchText)
        if let searchURL = URL(string: searchURLString) {
          browser.newTab(searchURL)
        }
      }
    }
  }
}
