//
//  PlainCheckboxButtonStyle.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct PlainButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(1.0)
      .scaleEffect(1.0)
      .animation(nil, value: configuration.isPressed)
  }
}
