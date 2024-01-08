//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

final class Tab: Identifiable {
  let id = UUID()
  var title: String
  var webURL: String
  
  init(title: String = "New Tab", webURL: String) {
    self.title = title
    self.webURL = webURL
  }
}
