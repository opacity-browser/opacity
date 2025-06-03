//
//  MoreMenuDialog.swift
//  Opacity
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI

struct MoreMenuDialog: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @Binding var isMoreMenuDialog: Bool
  
  @State private var isContactHover: Bool = false
  @State private var isZoomInHover: Bool = false
  @State private var isZoomOutHover: Bool = false
  @State private var isNewTabHover: Bool = false
  @State private var isNewWindowHover: Bool = false
  @State private var isSettingHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "envelope")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("Contact Us", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isContactHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isContactHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            NSWorkspace.shared.open(URL(string: "mailto:me@falsy.me")!)
            isMoreMenuDialog = false
          }
        }
        
        
        Divider()
          .padding(.vertical, 4)
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "plus.magnifyingglass")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("Zoom In", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
          Image(systemName: "command")
            .frame(maxWidth: 14, maxHeight: 14)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 11))
            .opacity(0.4)
          Text("+")
            .frame(width: 8)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 12))
            .opacity(0.4)
            .offset(y: -1)
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isZoomInHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isZoomInHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            tab.isZoomDialog = true
            tab.zoomLevel = ((tab.zoomLevel * 10) + 1) / 10
            isMoreMenuDialog = false
          }
        }
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "minus.magnifyingglass")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("Zoom Out", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
          Image(systemName: "command")
            .frame(maxWidth: 14, maxHeight: 14)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 11))
            .opacity(0.4)
          Text("-")
            .foregroundColor(Color("Icon"))
            .frame(width: 8)
            .font(.system(size: 12))
            .opacity(0.4)
            .offset(y: -1)
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isZoomOutHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isZoomOutHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            tab.isZoomDialog = true
            tab.zoomLevel = ((tab.zoomLevel * 10) - 1) / 10
            isMoreMenuDialog = false
          }
        }
        
        Divider()
          .padding(.vertical, 4)
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "rectangle.badge.plus")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
              .offset(y: 1)
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("New Tab", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
          Image(systemName: "command")
            .frame(maxWidth: 14, maxHeight: 14)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 11))
            .opacity(0.4)
          Text("T")
            .frame(width: 8)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 12))
            .opacity(0.4)
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isNewTabHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isNewTabHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            browser.initTab()
            isMoreMenuDialog = false
          }
        }
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "macwindow.badge.plus")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
              .offset(y: 1)
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("New Window", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
          Image(systemName: "command")
            .frame(maxWidth: 14, maxHeight: 14)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 11))
            .opacity(0.4)
          Text("N")
            .frame(width: 8)
            .foregroundColor(Color("Icon"))
            .font(.system(size: 12))
            .opacity(0.4)
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isNewWindowHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isNewWindowHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            AppDelegate.shared.newWindow()
            isMoreMenuDialog = false
          }
        }
        
        Divider()
          .padding(.vertical, 4)
        
        HStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "gearshape")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 14))
              .foregroundColor(Color("Icon"))
          }
          .frame(maxWidth: 20, maxHeight: 20)
          .padding(.leading, 5)
          Text(NSLocalizedString("Settings", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isSettingHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isSettingHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            browser.openSettings()
            isMoreMenuDialog = false
          }
        }
        
      }
      .padding(5)
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
