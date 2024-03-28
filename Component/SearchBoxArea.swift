//
//  SearchBox.swift
//  Opacity
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI

struct SearchBoxArea: View {
  @ObservedObject var browser: Browser
  
  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        VStack(spacing: 0) { }
        .frame(maxWidth: .infinity, maxHeight: 32)
        .onAppear {
          browser.searchBoxRect = geometry.frame(in: .global)
        }
        .onChange(of: geometry.size) { _, newValue in
          browser.searchBoxRect = geometry.frame(in: .global)
        }
      }
    }
  }
}
  
