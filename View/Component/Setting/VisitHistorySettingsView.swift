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
  
  var body: some View {
    VStack(spacing: 24) {
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
      
      if visitHistories.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "clock")
            .font(.system(size: 48))
            .foregroundColor(Color("Icon").opacity(0.3))
          
          Text(NSLocalizedString("There is no visit history.", comment: ""))
            .font(.system(size: 16))
            .foregroundColor(Color("UIText").opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        LazyVStack(spacing: 8) {
          ForEach(visitHistories.prefix(50), id: \.id) { history in
            if let visitGroup = history.visitHistoryGroup {
              VisitHistoryRow(
                title: visitGroup.title ?? visitGroup.url,
                url: visitGroup.url,
                date: history.createDate,
                faviconData: visitGroup.faviconData
              )
            }
          }
        }
      }
      
      Spacer()
    }
    .alert(NSLocalizedString("Clear All", comment: ""), isPresented: $showingClearAlert) {
      Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
      Button(NSLocalizedString("Delete", comment: ""), role: .destructive) {
        VisitManager.deleteAllVisitHistory()
      }
    } message: {
      Text(NSLocalizedString("Clear All", comment: ""))
    }
  }
}

struct VisitHistoryRow: View {
  let title: String
  let url: String
  let date: Date
  let faviconData: Data?
  
  var body: some View {
    HStack(spacing: 0) {
      Group {
        if let faviconData = faviconData, let nsImage = NSImage(data: faviconData) {
          Image(nsImage: nsImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          Image(systemName: "globe")
            .font(.system(size: 12))
            .foregroundColor(Color("Point"))
        }
      }
      .frame(width: 16, height: 16)
      .clipShape(RoundedRectangle(cornerRadius: 3))
      
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 14))
          .foregroundColor(Color("UIText"))
          .lineLimit(1)
        
        HStack(spacing: 0) {
          Text(url)
            .font(.system(size: 12))
            .foregroundColor(Color("Point").opacity(0.8))
            .lineLimit(1)
          
          Text(" • ")
            .font(.system(size: 12))
            .foregroundColor(Color("UIText").opacity(0.4))
          
          Text(formatDate(date))
            .font(.system(size: 12))
            .foregroundColor(Color("UIText").opacity(0.6))
        }
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
