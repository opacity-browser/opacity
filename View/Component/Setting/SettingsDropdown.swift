//
//  SettingsDropdown.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsDropdown: View {
  @Binding var selection: String
  let options: [String]
  
  var body: some View {
    Menu {
      ForEach(options, id: \.self) { option in
        Button(option) {
          selection = option
        }
      }
    } label: {
      HStack(spacing: 0) {
        Text(selection)
          .font(.system(size: 14))
          .foregroundColor(Color("UIText"))
        
        Spacer()
        
        Image(systemName: "chevron.up.chevron.down")
          .font(.system(size: 12))
          .foregroundColor(Color("Icon"))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color("InputBG"))
          .stroke(Color("UIBorder"), lineWidth: 0.5)
      )
    }
    .buttonStyle(.plain)
    .frame(width: 200)
  }
}
