//
//  SettingsRow.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
  let title: String
  let content: () -> Content
  
  init(title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }
  
  var body: some View {
    HStack(spacing: 0) {
      Text(title)
        .font(.system(size: 14))
        .foregroundColor(Color("UIText"))
        .frame(width: 120, alignment: .leading)
      
      Spacer()
        .frame(width: 40)
      
      content()
        .frame(width: 280, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
