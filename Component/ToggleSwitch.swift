//
//  ToggleSwitch.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI

struct ToggleSwitch: View {
  @Binding var isOn: Bool
      
  var body: some View {
    HStack {
      Rectangle()
        .foregroundColor(isOn ? Color("ButtonBG") : Color("ButtonCancelBG"))
        .frame(width: 28, height: 16)
        .cornerRadius(15)
        .overlay(
          Circle()
            .foregroundColor(.white)
            .padding(2)
            .offset(x: isOn ? 6 : -6)
        )
        .animation(.easeInOut(duration: 0.2), value: isOn)
        .onTapGesture {
          self.isOn.toggle()
        }
    }
  }
}
