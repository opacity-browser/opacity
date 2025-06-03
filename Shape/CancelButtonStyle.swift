//
//  CancelButtonStyle.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI

struct CancelButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(Color("ButtonCancelText"))
      .font(.system(size: 12))
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(configuration.isPressed ? Color("InputBGHover") : Color("InputBG"))
      .cornerRadius(5)
  }
}
