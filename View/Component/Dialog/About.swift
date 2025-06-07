//
//  About.swift
//  Opacity
//
//  Created by Falsy on 5/16/24.
//

import SwiftUI

struct About: View {
  var body: some View {
    VStack(spacing: 0) {
      Image("Logo")
        .resizable()
        .frame(width: 48, height: 48)
        .padding(.bottom, 5)
      Text("Opacity Browser")
        .font(.system(size: 14))
        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        .padding(.vertical, 7)
      if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        Text("version \(version)")
          .font(.system(size: 11))
      }
      Text("© 2025 Falsy.")
        .font(.system(size: 11))
        .padding(.top, 7)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 60)
  }
}
