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
        .padding(.bottom, 15)
      
      Button(NSLocalizedString("Open Settings", comment: "")) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
          NSWorkspace.shared.open(url)
        }
      }
      .buttonStyle(DialogButtonStyle())
    }
    .frame(width: 200)
    .padding(.horizontal, 10)
    .padding(.top, 15)
    .padding(.bottom, 10)
  }
}
