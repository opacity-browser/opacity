//
//  HistorySite.swift
//  Opacity
//
//  Created by Falsy on 2/18/24.
//

import SwiftUI

enum HistorySiteType {
  case webPage
  case newTab
  case settings
  case errorPage
}

final class HistorySite: ObservableObject, Identifiable {
  var id = UUID()
  @Published var title: String
  @Published var url: URL
  @Published var favicon: Image? = nil
  var siteType: HistorySiteType = .webPage
  var errorType: ErrorPageType? = nil
  var faviconOpacity: Double = 1.0
  
  init(title: String, url: URL, siteType: HistorySiteType = .webPage, errorType: ErrorPageType? = nil) {
    self.title = title
    self.url = url
    self.siteType = siteType
    self.errorType = errorType
    
    // 특수 페이지의 경우 기본 파비콘 설정
    if siteType != .webPage {
      setDefaultFavicon()
    }
  }
  
  private func setDefaultFavicon() {
    switch siteType {
    case .newTab, .settings, .errorPage:
      // 모든 특수 페이지에 MainLogo 사용
      self.favicon = Image("MainLogo")
      self.faviconOpacity = 0.6
    case .webPage:
      break
    }
  }
  
  func loadFavicon(url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, let uiImage = NSImage(data: data) else {
        return
      }
      self.favicon = Image(nsImage: uiImage)
    }.resume()
  }
}
