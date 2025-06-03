//
//  SettingsActionButtonStyle.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsActionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 14))
      .foregroundColor(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(configuration.isPressed ? Color("Danger").opacity(0.8) : Color("Danger"))
      )
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}
