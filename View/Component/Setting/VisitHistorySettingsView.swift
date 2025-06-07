//
//  VisitHistorySettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct VisitHistorySettingsView: View {
  @Query(sort: \VisitHistory.createDate, order: .reverse) var visitHistories: [VisitHistory]
  @State private var showingClearAlert = false
  @State private var displayCount = 30
  @State private var searchKeyword = ""
  @ObservedObject var browser: Browser
  
  init(browser: Browser) {
    self.browser = browser
  }
  
  var filteredHistories: [VisitHistory] {
    if searchKeyword.isEmpty {
      return visitHistories
    } else {
      return visitHistories.filter { history in
        let title = history.visitHistoryGroup?.title ?? ""
        let url = history.visitHistoryGroup?.url ?? ""
        return title.localizedCaseInsensitiveContains(searchKeyword) || 
               url.localizedCaseInsensitiveContains(searchKeyword)
      }
    }
  }
  
  var groupedHistories: [(date: Date, histories: [VisitHistory])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: filteredHistories.prefix(displayCount)) { history in
      calendar.startOfDay(for: history.createDate)
    }
    return grouped.sorted { $0.key > $1.key }.map { (date: $0.key, histories: $0.value) }
  }
  
  var body: some View {
    VStack(spacing: 32) {
      HStack(spacing: 0) {
        Text(NSLocalizedString("Visit History", comment: ""))
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
                NSLocalizedString("There is no visit history.", comment: "") :
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
                if history.visitHistoryGroup != nil {
                  VisitHistoryRow(visitHistory: history, browser: browser)
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
        VisitManager.deleteAllVisitHistory()
      }
    } message: {
      Text(NSLocalizedString("Are you sure you want to clear all visit history?", comment: ""))
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

struct VisitHistoryRow: View {
  let visitHistory: VisitHistory
  let browser: Browser
  @State private var isHovering = false
  @State private var isHoveringDelete = false
  @Environment(\.modelContext) private var modelContext
  
  var visitGroup: VisitHistoryGroup? {
    visitHistory.visitHistoryGroup
  }
  
  var title: String {
    visitGroup?.title ?? visitGroup?.url ?? ""
  }
  
  var url: String {
    visitGroup?.url ?? ""
  }
  
  var date: Date {
    visitHistory.createDate
  }
  
  var faviconData: Data? {
    visitGroup?.faviconData
  }
  
  var body: some View {
    Button(action: {
      performVisit()
    }) {
      HStack(spacing: 0) {
        Group {
          if let faviconData = faviconData, let nsImage = NSImage(data: faviconData) {
            Image(nsImage: nsImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
          } else {
            Image(systemName: "globe")
              .font(.system(size: 14))
              .foregroundColor(Color("Icon"))
          }
        }
        .frame(width: 16, height: 16)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.system(size: 14))
            .foregroundColor(Color("UIText"))
            .lineLimit(1)
          
          Text(url)
            .font(.system(size: 12))
            .foregroundColor(Color("Point").opacity(0.4))
            .lineLimit(1)
        }
        .padding(.leading, 12)
        
        Spacer()
        
        Text(formatTime(date))
          .font(.system(size: 12))
          .foregroundColor(Color("UIText").opacity(0.6))
          .padding(.trailing, 12)
        
        if isHovering {
          Button(action: {
            deleteVisitHistory()
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
            deleteVisitHistory()
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
  
  private func deleteVisitHistory() {
    modelContext.delete(visitHistory)
    try? modelContext.save()
  }
  
  private func performVisit() {
    if let url = URL(string: url) {
      browser.newTab(url)
    }
  }
}
