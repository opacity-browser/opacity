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
      Text(NSLocalizedString("Open Settings", comment: ""))
        .font(.system(size: 12))
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .buttonStyle(.plain)
        .background(Color("MainBlack"))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .onTapGesture {
          if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
          }
        }
    }
    .frame(width: 200)
    .padding(.horizontal, 10)
    .padding(.top, 15)
    .padding(.bottom, 10)
  }
}
