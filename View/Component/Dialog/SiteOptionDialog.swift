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
  @Query var generalSetting: [GeneralSetting]
  
  @ObservedObject var service: Service
  @ObservedObject var tab: Tab
  @State var cacheBlockingLevel: String?
  
  init(service: Service, tab: Tab) {
    self.service = service
    self.tab = tab
    self._cacheBlockingLevel = State(initialValue: service.blockingLevel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(NSLocalizedString("Tracker blocking", comment: ""))
        Spacer()
        Picker("", selection: $service.blockingLevel) {
          Text(NSLocalizedString("blocking-strong", comment: "")).tag("blocking-strong")
          Text(NSLocalizedString("blocking-moderate", comment: "")).tag("blocking-moderate")
          Text(NSLocalizedString("blocking-light", comment: "")).tag("blocking-light")
          Text(NSLocalizedString("blocking-none", comment: "")).tag("blocking-none")
        }
        .frame(maxWidth: .infinity)
      }
    
      Divider()
        .padding(.top, 5)
  
      HStack(spacing: 0) {
        Text(
          service.blockingLevel == "blocking-strong" ?
          NSLocalizedString("blocking-light-exp", comment: "")
          : service.blockingLevel == "blocking-moderate" ?
          NSLocalizedString("blocking-moderate-exp", comment: "")
          : service.blockingLevel == "blocking-light" ?
          NSLocalizedString("blocking-strong-exp", comment: "")
          : NSLocalizedString("blocking-none-exp", comment: "")
        )
        .font(.system(size: 11))
        .foregroundStyle(Color("UIText"))
        .opacity(0.5)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        Spacer()
      }
      .padding(.top, 5)
      
      if let cache = cacheBlockingLevel, cache != service.blockingLevel {
        HStack(spacing: 0) {
          Text(NSLocalizedString("blocking-change-text", comment: ""))
            .font(.system(size: 11))
            .foregroundStyle(Color("AlertText"))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
          Spacer()
        }
        .padding(.top, 5)
      }
      
    }
    .frame(width: 220)
    .padding(.horizontal, 20)
    .padding(.top, 15)
    .padding(.bottom, 15)
    .background(GeometryReader { geometry in
      Color("WindowTitleBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
    .onChange(of: service.blockingLevel) { oV, nV in
      if let generalSetting = generalSetting.first {
        generalSetting.blockingLevel = nV
      }
    }
  }
}
