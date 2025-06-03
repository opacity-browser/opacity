//
//  SaveButtonStyle.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI

struct SaveButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(Color("ButtonText"))
      .font(.system(size: 12))
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(configuration.isPressed ? Color("ButtonBGHover") : Color("ButtonBG"))
      .cornerRadius(5)
  }
}
