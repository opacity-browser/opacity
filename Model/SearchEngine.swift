//
//  SearchEngine.swift
//  Opacity
//
//  Created by Falsy on 1/21/24.
//

import SwiftUI

final class SearchEngine: Identifiable {
  var id = UUID()
  var name: String
  var url: URL
  var logo: NSImage?
  
  init(name: String, url: URL, logo: NSImage?) {
    self.name = name
    self.url = url
    self.logo = logo
  }
}
