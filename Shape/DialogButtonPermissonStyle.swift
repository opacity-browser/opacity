//
//  DialogPermissonStyle.swift
//  Opacity
//
//  Created by Falsy on 8/11/24.
//

import SwiftUI

struct DialogPermissonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(Color("UIText"))
      .font(.system(size: 12))
      .padding(.horizontal, 20)
      .padding(.vertical, 6)
      .background(configuration.isPressed ? Color("DialogPermissionButton").opacity(1) : Color("DialogPermissionButton").opacity(0.8))
      .cornerRadius(5)
      .frame(maxWidth: .infinity)
  }
}
