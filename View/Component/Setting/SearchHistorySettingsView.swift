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
  
  var body: some View {
    VStack(spacing: 24) {
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
      
      if searchHistories.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 48))
            .foregroundColor(Color("Icon").opacity(0.3))
          
          Text(NSLocalizedString("There is no search history.", comment: ""))
            .font(.system(size: 16))
            .foregroundColor(Color("UIText").opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        LazyVStack(spacing: 8) {
          ForEach(searchHistories.prefix(50), id: \.id) { history in
            if let searchText = history.searchHistoryGroup?.searchText {
              SearchHistoryRow(searchText: searchText, date: history.createDate)
            }
          }
        }
      }
      
      Spacer()
    }
    .alert(NSLocalizedString("Clear All", comment: ""), isPresented: $showingClearAlert) {
      Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
      Button(NSLocalizedString("Delete", comment: ""), role: .destructive) {
        SearchManager.deleteAllSearchHistory()
      }
    } message: {
      Text(NSLocalizedString("Clear All", comment: ""))
    }
  }
}

struct SearchHistoryRow: View {
  let searchText: String
  let date: Date
  
  var body: some View {
    HStack(spacing: 0) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 14))
        .foregroundColor(Color("Icon"))
        .frame(width: 20, height: 20)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(searchText)
          .font(.system(size: 14))
          .foregroundColor(Color("UIText"))
          .lineLimit(1)
        
        Text(formatDate(date))
          .font(.system(size: 12))
          .foregroundColor(Color("UIText").opacity(0.6))
      }
      .padding(.leading, 12)
      
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color("InputBG").opacity(0.5))
    )
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale.current
    return formatter.string(from: date)
  }
}
