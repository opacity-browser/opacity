//
//  ContentView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      NavigationSplitView {
        HStack {
          Text("navigation")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      } detail: {
        VStack {
          Text("title area")
            .frame(maxWidth: .infinity, minHeight: 38.0)
          Spacer()
          Text("content")
            .frame(maxWidth: .infinity, alignment: .leading)
          Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
        .multilineTextAlignment(.leading)
      }
      .border(.red, width: 0)
    }
  }
}

#Preview {
    ContentView()
}
