//
//  TitleView.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

struct Navigation: View {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @State private var isSidebarHover: Bool = false
  @State private var isMoreHover: Bool = false
  @State private var isLocaionHover: Bool = false
  @State private var isNotificationHover: Bool = false
  @State private var isDownloadHover: Bool = false
  
  @State private var isNotificationDetailDialog: Bool = true
  @State private var isLocationDetailDialog: Bool = true
  @State private var isMoreMenuDialog: Bool = false
  @State private var isDownloadDetailDialog: Bool = true

  let inputHeight: CGFloat = 32
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  let textSize: CGFloat = 13.5
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 10)
      
      HistoryBackBtn(tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      HistoryForwardBtn(tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      HistoryRefreshBtn(iconHeight: iconHeight, iconRadius: iconRadius)
      
      VStack(spacing: 0) { }.frame(width: 11)
      
      Spacer()
      
      SearchBoxArea(browser: browser)
      
      Spacer()
      
      VStack(spacing: 0) { }.frame(width: 11)
      
      if let download = service.downloads.first(where: { $0.isDownloading == true }) {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "square.and.arrow.down")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isDownloadHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onHover { inside in
            withAnimation {
              isDownloadHover = inside
            }
          }
          .onTapGesture {
            isDownloadDetailDialog.toggle()
          }
          .popover(isPresented: $isDownloadDetailDialog, arrowEdge: .bottom) {
            
          }
        }
        .padding(.trailing, 13)
      }
      
      if tab.isNotificationDialogIcon {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "bell.slash")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isNotificationHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onHover { inside in
            withAnimation {
              isNotificationHover = inside
            }
          }
          .onTapGesture {
            isNotificationDetailDialog.toggle()
          }
          .popover(isPresented: $isNotificationDetailDialog, arrowEdge: .bottom) {
            NotificationDialog(tab: tab)
          }
        }
        .padding(.trailing, 13)
      }
      
      if tab.isLocationDialogIcon {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "location.slash")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isLocaionHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onHover { inside in
            withAnimation {
              isLocaionHover = inside
            }
          }
          .onTapGesture {
            isLocationDetailDialog.toggle()
          }
          .popover(isPresented: $isLocationDetailDialog, arrowEdge: .bottom) {
            GeoLocationDialog()
          }
        }
        .padding(.trailing, 13)
      }
      
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "sidebar.right")
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
            .opacity(0.9)
        }
        .frame(maxWidth: iconHeight, maxHeight: iconHeight)
        .background(isSidebarHover || browser.isSideBar ? .gray.opacity(0.2) : .gray.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: iconRadius))
        .onHover { hovering in
          withAnimation {
            isSidebarHover = hovering
          }
        }
        .onTapGesture {
          browser.isSideBar.toggle()
        }
        .offset(y: -1)
      }
      .padding(.trailing, 13)
      
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "ellipsis")
            .rotationEffect(.degrees(90))
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
        }
        .frame(maxWidth: iconHeight, maxHeight: iconHeight)
        .background(isMoreHover ? .gray.opacity(0.2) : .gray.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: iconRadius))
        .onHover { hovering in
          withAnimation {
            isMoreHover = hovering
          }
        }
        .onTapGesture {
          self.isMoreMenuDialog.toggle()
        }
        .popover(isPresented: $isMoreMenuDialog, arrowEdge: .bottom) {
          MoreMenuDialog(browser: browser, isMoreMenuDialog: $isMoreMenuDialog)
//            .background(Color("SearchBarBG"))
        }
        .offset(y: -1)
      }
      .padding(.trailing, 10)
    }
    .frame(height: 36)
    .offset(y: -1)
  }
}

