//
//  WebviewArea.swift
//  Opacity
//
//  Created by Falsy on 4/11/24.
//

import SwiftUI

struct WebviewArea: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  var body: some View {
    VStack(spacing: 0) {
      WebNSView(browser: browser, tab: tab)
    }
    .background(tab.originURL.scheme == "opacity" ? Color("SearchBarBG") : .white)
  }
}
