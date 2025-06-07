//
//  PermissionsSettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct PermissionsSettingsView: View {
  @Query var domainPermissions: [DomainPermission]
  @ObservedObject var browser: Browser  // browser 추가
  
  init(browser: Browser) {
    self.browser = browser
  }
  
  private var notificationPermissions: [DomainPermission] {
    domainPermissions.filter { $0.permission == DomainPermissionType.notification.rawValue }
  }
  
  private var locationPermissions: [DomainPermission] {
    domainPermissions.filter { $0.permission == DomainPermissionType.geoLocation.rawValue }
  }
  
  var body: some View {
    VStack(spacing: 32) {
      VStack(alignment: .leading, spacing: 24) {
        Text(NSLocalizedString("Permissions", comment: ""))
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
          .padding(.bottom, 2)
        
        PermissionSection(
          title: NSLocalizedString("Notification", comment: ""),
          icon: "bell",
          permissions: notificationPermissions
        )
        
        PermissionSection(
          title: NSLocalizedString("Location", comment: ""),
          icon: "location",
          permissions: locationPermissions
        )
      }
      
      Spacer()
    }
  }
}

struct PermissionSection: View {
  let title: String
  let icon: String
  let permissions: [DomainPermission]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 0) {
        Image(systemName: icon)
          .font(.system(size: 16))
          .foregroundColor(Color("Point"))
          .frame(width: 20, height: 20)
        
        Text(title)
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(Color("UIText"))
          .padding(.leading, 8)
        
        Spacer()
      }
      
      if permissions.isEmpty {
        VStack(spacing: 8) {
          Text(NSLocalizedString("There is no domain with permissions set.", comment: ""))
            .font(.system(size: 14))
            .foregroundColor(Color("UIText").opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color("InputBG").opacity(0.3))
        )
      } else {
        VStack(spacing: 8) {
          ForEach(permissions, id: \.id) { permission in
            PermissionRow(permission: permission)
          }
        }
      }
    }
  }
}

struct PermissionRow: View {
  @Environment(\.modelContext) var modelContext
  let permission: DomainPermission
  @State private var isHovering = false
  @State private var isHoveringDelete = false
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 4) {
        Text(permission.domain)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(Color("UIText"))
        
        Text(!permission.isDenied ? NSLocalizedString("allowed", comment: "") : NSLocalizedString("denied", comment: ""))
          .font(.system(size: 12))
          .foregroundColor(permission.isDenied ? Color("DenyColor") : Color("AllowColor"))
      }
      
      Spacer()
      
      if isHovering {
        Button(action: {
          deletePermission()
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(Color("UIText").opacity(0.6))
            .frame(width: 20, height: 20)
            .background(
              Circle()
                .fill(Color("UIText").opacity(isHoveringDelete ? 0.15 : 0))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
          isHoveringDelete = hovering
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color("InputBG").opacity(0.5))
    )
    .onHover { hovering in
      isHovering = hovering
    }
  }
  
  private func deletePermission() {
    modelContext.delete(permission)
    try? modelContext.save()
  }
}
