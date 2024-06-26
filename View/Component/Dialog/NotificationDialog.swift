//
//  NotificationDialog.swift
//  Opacity
//
//  Created by Falsy on 2/28/24.
//

import SwiftUI
import SwiftData

struct NotificationDialog: View {
  @Environment(\.modelContext) var modelContext
  @Query var domainPermission: [DomainPermission]
  
  @ObservedObject var tab: Tab
  
  var body: some View {
    let host = tab.originURL.host ?? ""
    VStack(spacing: 0) {
      
      Text(String(format: NSLocalizedString("Do you want to allow notifications from '%@'?", comment: ""), host))
        .font(.system(size: 12))
        .padding(.bottom, 15)
      
      HStack(spacing: 0) {
        Button(NSLocalizedString("Allow", comment: "")) {
          guard let domainNotification = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.notification.rawValue
          }) else {
            modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.notification.rawValue, isDenied: false))
            withAnimation {
              tab.isNotificationDialogIcon = false
            }
            return
          }
          withAnimation {
            domainNotification.isDenied = false
            tab.isNotificationDialogIcon = false
          }
        }
        .buttonStyle(DialogButtonStyle())
        VStack(spacing: 0) { }.frame(width: 10)
        Button(NSLocalizedString("Deny", comment: "")) {
          guard let domainNotification = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.notification.rawValue
          }) else {
            modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.notification.rawValue, isDenied: true))
            withAnimation {
              tab.isNotificationDialogIcon = false
            }
            return
          }
          withAnimation {
            domainNotification.isDenied = true
            tab.isNotificationDialogIcon = false
          }
        }
        .buttonStyle(DialogButtonCancelStyle())
      }
    }
    .frame(width: 200)
    .padding(.horizontal, 10)
    .padding(.top, 15)
    .padding(.bottom, 10)
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
