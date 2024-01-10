//
//  Tab.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

final class Tab: ObservableObject {
  let id = UUID()
  let webURL: String
  @Published var title: String
  
  init(title: String = "New Tab", webURL: String) {
    self.title = title
    self.webURL = webURL
  }
}
