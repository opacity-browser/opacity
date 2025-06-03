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
  
  @State private var isAllowed: Bool
  
  init(permission: DomainPermission) {
    self.permission = permission
    self._isAllowed = State(initialValue: !permission.isDenied)
  }
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 4) {
        Text(permission.domain)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(Color("UIText"))
        
        Text(isAllowed ? NSLocalizedString("allowed", comment: "") : NSLocalizedString("denied", comment: ""))
          .font(.system(size: 12))
          .foregroundColor(isAllowed ? Color("Point") : Color("Danger"))
      }
      
      Spacer()
      
      Toggle("", isOn: $isAllowed)
        .toggleStyle(SwitchToggleStyle(tint: Color("Point")))
        .scaleEffect(0.8)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color("InputBG").opacity(0.5))
    )
    .onChange(of: isAllowed) { _, newValue in
      permission.isDenied = !newValue
      try? modelContext.save()
    }
  }
}
