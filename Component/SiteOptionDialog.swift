//
//  SiteOptionDialog.swift
//  Opacity
//
//  Created by Falsy on 2/29/24.
//

import SwiftUI
import SwiftData
import UserNotifications

struct SiteOptionDialog: View {
  @Environment(\.modelContext) var modelContext
  @Query var domainPermission: [DomainPermission]
  
  @ObservedObject var tab: Tab
  
  var body: some View {
    VStack(spacing: 0) {
      if let host = tab.originURL.host {
        if tab.isNotificationPermissionByApp {
          if let domainNotification = domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.notification.rawValue
          }) {
            HStack(spacing: 0) {
              VStack(spacing: 0) {
                Image(systemName: "bell")
                  .foregroundColor(Color("Icon"))
                  .font(.system(size: 14))
                  .fontWeight(.regular)
              }
              .padding(.trailing, 7)
              Text(NSLocalizedString("Notification", comment: ""))
              Spacer()
              ToggleSwitch(isOn: $tab.isNotificationPermission)
                .frame(width: 40, height: 20)
                .onChange(of: tab.isNotificationPermission) { _, newValue in
                  domainNotification.isDenied = !newValue
                  if newValue && tab.isNotificationDialogIcon {
                    withAnimation {
                      tab.isNotificationDialogIcon = false
                    }
                  }
                }
            }
          }
        }
      }
    }
    .frame(width: 200)
    .padding(.horizontal, 20)
    .padding(.top, 15)
    .padding(.bottom, 15)
  }
}
