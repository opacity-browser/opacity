//
//  DialogButtonCancelStyle.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct DialogButtonCancelStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .font(.system(size: 12))
      .padding(.horizontal, 15)
      .padding(.vertical, 6)
      .background(configuration.isPressed ? Color("ButtonCancelBGHover") : Color("ButtonCancelBG"))
      .cornerRadius(5)
  }
}
