//
//  LocationHostDialog.swift
//  Opacity
//
//  Created by Falsy on 8/11/24.
//

import SwiftUI
import SwiftData

struct LocationHostDialog: View {
  @Environment(\.modelContext) var modelContext
  @Query var domainPermission: [DomainPermission]
  
  @ObservedObject var tab: Tab
  var onClose: () -> Void
  
  var body: some View {
    let host = tab.originURL.host ?? ""
    VStack(spacing: 0) {
      
      Text(String(format: NSLocalizedString("Allow '%@' to use your location?", comment: ""), host))
        .font(.system(size: 12))
        .fontWeight(.semibold)
        .padding(.bottom, 15)
        .foregroundColor(Color("UIText").opacity(0.7))
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .padding(.horizontal, 20)
      
      HStack(spacing: 0) {
        Button {
          guard let domainLocation = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.geoLocation.rawValue
          }) else {
            modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.geoLocation.rawValue, isDenied: false))
            onClose()
            return
          }
          domainLocation.isDenied = false
          onClose()
        } label: {
          Text(NSLocalizedString("Allow", comment: ""))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DialogPermissonStyle())
        .frame(maxWidth: .infinity)
        
        HStack(spacing: 0) { }
          .frame(width: 12)
        
        Button {
          guard let domainLocation = self.domainPermission.first(where: {
            $0.domain == host && $0.permission == DomainPermissionType.geoLocation.rawValue
          }) else {
            modelContext.insert(DomainPermission(domain: host, permission: DomainPermissionType.notification.rawValue, isDenied: true))
            onClose()
            return
          }
          domainLocation.isDenied = true
          onClose()
        } label: {
          Text(NSLocalizedString("Deny", comment: ""))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DialogPermissonStyle())
        .frame(maxWidth: .infinity)
      } 
      .frame(maxWidth: .infinity)
    }
    .frame(width: 240)
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
  }
}
