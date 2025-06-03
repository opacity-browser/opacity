//
//  ButtonStyle.swift
//  Opacity
//
//  Created by Falsy on 2/26/24.
//

import SwiftUI

struct DialogButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .font(.system(size: 12))
      .padding(.horizontal, 20)
      .padding(.vertical, 6)
      .background(configuration.isPressed ? Color("ButtonBGHover") : Color("ButtonBG"))
      .cornerRadius(5)
      .frame(maxWidth: .infinity)
  }
}
