//
//  LibrarySettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct LibrarySettingsView: View {
  @ObservedObject var browser: Browser
    
  init(browser: Browser) {
    self.browser = browser
  }
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(alignment: .leading, spacing: 24) {
        Text(NSLocalizedString("Library", comment: ""))
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
          .padding(.bottom, 6)
        
        VStack(spacing: 16) {
          LibraryInfoRow(
            title: "Tracker Radar Kit",
            description: "Apache 2.0 license",
            link: "https://github.com/duckduckgo/TrackerRadarKit",
            browser: browser
          )
          
          LibraryInfoRow(
            title: "Tracker Blocklists",
            description: "CC BY-NC-SA 4.0 license",
            link: "https://github.com/duckduckgo/tracker-blocklists",
            browser: browser
          )
          
          LibraryInfoRow(
            title: "Remove Adblock Thing",
            description: "MIT license",
            link: "https://github.com/TheRealJoelmatic/RemoveAdblockThing",
            browser: browser
          )
          
          LibraryInfoRow(
            title: "ASN1Decoder",
            description: "MIT license",
            link: "https://github.com/filom/ASN1Decoder",
            browser: browser
          )
        }
      }
      
      Spacer()
    }
  }
}

struct LibraryInfoRow: View {
  let title: String
  let description: String
  let link: String?
  @ObservedObject var browser: Browser
  
  init(title: String, description: String, link: String? = nil, browser: Browser) {
    self.title = title
    self.description = description
    self.link = link
    self.browser = browser
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 0) {
        if let link = link {
          Button(action: {
            browser.newTab(URL(string: link)!)
          }) {
            Text(title)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(Color("Point"))
              .underline()
          }
          .buttonStyle(.plain)
        } else {
          Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color("UIText"))
        }
        
        Spacer()
      }
      
      Text(description)
        .font(.system(size: 12))
        .foregroundColor(Color("UIText").opacity(0.6))
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
