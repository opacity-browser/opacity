//
//  MoreMenuDialog.swift
//  Opacity
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI

struct MoreMenuDialog: View {
  @ObservedObject var browser: Browser
  @Binding var isMoreMenuDialog: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text("Settings")
          .font(.system(size: 13))
        Spacer()
      }
      .frame(height: 36)
      .padding(.horizontal, 10)
      .background(Color("SearchBarBG"))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .onTapGesture {
        if let schemeURL = URL(string:"opacity://settings") {
          DispatchQueue.main.async {
            browser.newTab(schemeURL)
            isMoreMenuDialog = false
          }
        }
      }
    }
    .frame(width: 200)
    .padding(10)
  }
}
