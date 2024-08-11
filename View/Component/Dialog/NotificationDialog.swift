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
        .fontWeight(.semibold)
        .padding(.bottom, 15)
        .foregroundColor(Color("UIText").opacity(0.7))
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .padding(.horizontal, 20)
      
      HStack(spacing: 0) {
        Button {
          if let domainNotification = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.notification.rawValue
          }) {
            DispatchQueue.main.async {
              domainNotification.isDenied = false
              tab.isNotificationDialogIcon = false
            }
          } else {
            DispatchQueue.main.async {
              modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.notification.rawValue, isDenied: false))
              tab.isNotificationDialogIcon = false
            }
          }
          if let webview = tab.webview {
            DispatchQueue.main.async {
              webview.evaluateJavaScript("if (window.resolveNotificationPermission) window.resolveNotificationPermission('granted');")
            }
          }
        } label: {
          Text(NSLocalizedString("Allow", comment: ""))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DialogPermissonStyle())
        .frame(maxWidth: .infinity)
        
        VStack(spacing: 0) { }.frame(width: 12)
        
        Button {
          if let domainNotification = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.notification.rawValue
          }) {
            DispatchQueue.main.async {
              domainNotification.isDenied = true
              tab.isNotificationDialogIcon = false
            }
          } else {
            DispatchQueue.main.async {
              modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.notification.rawValue, isDenied: true))
              tab.isNotificationDialogIcon = false
            }
          }
          if let webview = tab.webview {
            DispatchQueue.main.async {
              webview.evaluateJavaScript("if (window.resolveNotificationPermission) window.resolveNotificationPermission('denied');")
            }
          }
        } label: {
          Text(NSLocalizedString("Deny", comment: ""))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DialogPermissonStyle())
        .frame(maxWidth: .infinity)
      }
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
    .onDisappear {
      if let webview = tab.webview {
        DispatchQueue.main.async {
          tab.isNotificationDialogIcon = false
          webview.evaluateJavaScript("if (window.resolveNotificationPermission) window.resolveNotificationPermission('default');")
        }
      }
    }
  }
}
