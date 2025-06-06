//
//  GeoLocationDialog.swift
//  Opacity
//
//  Created by Falsy on 2/26/24.
//

import SwiftUI

struct GeoLocationDialog: View {
  var body: some View {
    VStack(spacing: 0) {
      Text(NSLocalizedString("Location services are disabled in your Mac system settings", comment: ""))
        .font(.system(size: 12))
        .fontWeight(.semibold)
        .padding(.bottom, 15)
        .foregroundColor(Color("UIText").opacity(0.7))
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .padding(.horizontal, 20)
      
      Button {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
          NSWorkspace.shared.open(url)
        }
      } label: {
        Text(NSLocalizedString("Open Settings", comment: ""))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(DialogPermissonStyle())
      .frame(maxWidth: .infinity)
    }
    .frame(width: 220)
    .padding(.horizontal, 20)
    .padding(.top, 20)
    .padding(.bottom, 15)
    .background(GeometryReader { geometry in
      Color("DialogBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
}
