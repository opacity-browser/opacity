//
//  LibrarySettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct LibrarySettingsView: View {
  var body: some View {
    VStack(spacing: 32) {
      VStack(alignment: .leading, spacing: 24) {
        Text(NSLocalizedString("Library", comment: ""))
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
        
        VStack(spacing: 16) {
          LibraryInfoRow(
            title: "Opacity Browser",
            version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            description: NSLocalizedString("Private-focused web browser", comment: "")
          )
          
          LibraryInfoRow(
            title: "DuckDuckGo Tracker Radar",
            version: "1.0",
            description: NSLocalizedString("Rule list for tracker blocking", comment: "")
          )
          
          LibraryInfoRow(
            title: "WebKit",
            version: "Safari Technology Preview",
            description: NSLocalizedString("Web rendering engine", comment: "")
          )
        }
      }
      
      Spacer()
    }
  }
}

struct LibraryInfoRow: View {
  let title: String
  let version: String
  let description: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 0) {
        Text(title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(Color("UIText"))
        
        Spacer()
        
        Text("v\(version)")
          .font(.system(size: 14))
          .foregroundColor(Color("UIText").opacity(0.6))
      }
      
      Text(description)
        .font(.system(size: 14))
        .foregroundColor(Color("UIText").opacity(0.7))
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color("InputBG").opacity(0.5))
    )
  }
}
