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
  @State private var isFindHover: Bool = false
  @State private var isZoomHover: Bool = false
  
  @State private var isNotificationDetailDialog: Bool = true
  @State private var isMoreMenuDialog: Bool = false
  @State private var isFindDetailDialog: Bool = true

  let inputHeight: CGFloat = 32
  let iconHeight: CGFloat = 24
  let iconRadius: CGFloat = 6
  let textSize: CGFloat = 13.5
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(spacing: 0) { }.frame(width: 10)
      
      HistoryBackBtn(browser: browser, tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      HistoryForwardBtn(browser: browser, tab: tab)
      
      VStack(spacing: 0) { }.frame(width: 13)
      
      if tab.pageProgress > 0 && tab.pageProgress < 1 {
        HistoryStopBtn(tab: tab, iconHeight: iconHeight, iconRadius: iconRadius)
      } else {
        HistoryRefreshBtn(iconHeight: iconHeight, iconRadius: iconRadius)
      }
      
      VStack(spacing: 0) { }.frame(width: 11)
      
      Spacer()
      
      SearchBoxArea(browser: browser)
      
      Spacer()
      
      VStack(spacing: 0) { }.frame(width: 11)
      
      if tab.isZoomDialog {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "plus.magnifyingglass")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isZoomHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onTapGesture {
            tab.isZoomDialog.toggle()
          }
          .onHover { hover in
            withAnimation {
              isZoomHover = hover
            }
          }
          .popover(isPresented: $tab.isZoomDialog, arrowEdge: .bottom) {
            ZoomDialog(tab: tab)
          }
        }
        .padding(.trailing, 13)
      }
      
      if tab.isFindDialog {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "doc.text.magnifyingglass")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 14))
              .fontWeight(.regular)
          }
          .frame(maxWidth: iconHeight, maxHeight: iconHeight)
          .background(isFindHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: iconRadius))
          .onAppear {
            isFindDetailDialog = true
          }
          .onHover { hover in
            withAnimation {
              isFindHover = hover
            }
          }
          .onChange(of: isFindDetailDialog) { _, nV in
            if nV == false {
              DispatchQueue.main.async {
                tab.isFindDialog = false
              }
            }
          }
          .popover(isPresented: $isFindDetailDialog, arrowEdge: .bottom) {
            FindDialog(tab: tab)
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
          .onHover { hover in
            withAnimation {
              isNotificationHover = hover
            }
          }
          .onTapGesture {
            DispatchQueue.main.async {
              isNotificationDetailDialog.toggle()
            }
          }
          .popover(isPresented: $isNotificationDetailDialog, arrowEdge: .bottom) {
            NotificationDialog(tab: tab)
          }
        }
        .padding(.trailing, 13)
        .onAppear {
          isNotificationDetailDialog = true
        }
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
          .onHover { hover in
            withAnimation {
              isLocaionHover = hover
            }
          }
          .onTapGesture {
            DispatchQueue.main.async {
              tab.isLocationDialog.toggle()
            }
          }
          .popover(isPresented: $tab.isLocationDialog, arrowEdge: .bottom) {
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
        .onHover { hover in
          withAnimation {
            isSidebarHover = hover
          }
        }
        .onTapGesture {
          AppDelegate.shared.isSidebar()
        }
        .offset(y: -1)
      }
      .padding(.trailing, 13)
      
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Image(systemName: "ellipsis")
            .foregroundColor(Color("Icon"))
            .font(.system(size: 14))
            .fontWeight(.regular)
        }
        .frame(maxWidth: iconHeight, maxHeight: iconHeight)
        .background(isMoreHover ? .gray.opacity(0.2) : .gray.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: iconRadius))
        .onHover { hover in
          withAnimation {
            isMoreHover = hover
          }
        }
        .onTapGesture {
          DispatchQueue.main.async {
            isMoreMenuDialog.toggle()
          }
        }
        .popover(isPresented: $isMoreMenuDialog, arrowEdge: .bottom) {
          MoreMenuDialog(browser: browser, tab: tab, isMoreMenuDialog: $isMoreMenuDialog)
        }
        .offset(y: -1)
      }
      .padding(.trailing, 10)
    }
    .frame(height: 36)
    .offset(y: -1)
  }
}

