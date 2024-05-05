//
//  MoreMenuDialog.swift
//  Opacity
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI

struct MoreMenuDialog: View {
  @ObservedObject var browser: Browser
  @Binding var isMoreMenuDialog: Bool
  
  @State private var isSettingHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "gearshape")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text("Settings")
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
        }
        .padding(5)
        .padding(.vertical, 5)
        .onHover { hovering in
          isSettingHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isSettingHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          if let schemeURL = URL(string:"opacity://settings") {
            DispatchQueue.main.async {
              browser.newTab(schemeURL)
              isMoreMenuDialog = false
            }
          }
        }
      }
      .padding(10)
    }
    .frame(width: 220)
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
