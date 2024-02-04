//
//  Browser.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

final class Browser: ObservableObject {
  @Published var tabs: [Tab] = []
  @Published var index: Int = -1
  @Published var tabSize: CGSize?
  var tabPosition: CGPoint = CGPoint(x: 74, y: 0)
  
}
