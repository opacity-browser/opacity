//
//  HistorySite.swift
//  FriedEgg
//
//  Created by Falsy on 2/18/24.
//

import SwiftUI

final class HistorySite: ObservableObject, Identifiable {
  var id = UUID()
  @Published var title: String
  @Published var url: URL
  @Published var favicon: Image? = nil
  
  init(title: String, url: URL) {
    self.title = title
    self.url = url
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
