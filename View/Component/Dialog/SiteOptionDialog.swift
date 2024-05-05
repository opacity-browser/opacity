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
  @Query var generalSetting: [GeneralSetting]
  
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @State var cacheBlockingLevel: String?
  
  init(service: Service, browser: Browser, tab: Tab) {
    self.service = service
    self.tab = tab
    self.browser = browser
    self._cacheBlockingLevel = State(initialValue: service.blockingLevel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if tab.originURL.scheme == "opacity" {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "lock.circle.fill")
              .font(.system(size: 30))
              .foregroundColor(Color("Point"))
              .padding(.top, 10)
              .padding(.bottom, 15)
          }
          HStack(spacing: 0) {
            Text(NSLocalizedString("This connection is secure.", comment: ""))
            Spacer()
          }
          .padding(.bottom, 2)
          HStack(spacing: 0) {
            Text(NSLocalizedString("This is a page provided inside the app.", comment: ""))
              .opacity(0.5)
              .font(.system(size: 11))
            Spacer()
          }
        }
      } else if tab.isValidCertificate == false {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "exclamationmark.triangle.fill")
              .font(.system(size: 30))
              .foregroundColor(Color("AlertText"))
              .padding(.top, 10)
              .padding(.bottom, 15)
          }
          HStack(spacing: 0) {
            Text(NSLocalizedString("This connection is not secure.", comment: ""))
            Spacer()
          }
        }
      } else {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "lock.circle.fill")
              .font(.system(size: 30))
              .foregroundColor(Color("Point"))
              .padding(.top, 10)
              .padding(.bottom, 15)
          }
          HStack(spacing: 0) {
            Text(NSLocalizedString("This connection is secure.", comment: ""))
            Spacer()
          }
          .padding(.bottom, 2)
          HStack(spacing: 0) {
            Text(NSLocalizedString("Certificate summary:", comment: ""))
              .opacity(0.5)
              .font(.system(size: 11))
            Text(tab.certificateSummary)
              .font(.system(size: 11))
              .padding(.leading, 5)
            Spacer()
          }
        }
      }
      
      Divider()
        .padding(.vertical, 15)
      
      HStack(spacing: 0) {
        Text(NSLocalizedString("Tracker Blocking", comment: ""))
        Spacer()
        Picker("", selection: $service.blockingLevel) {
          Text(NSLocalizedString("blocking-strong", comment: "")).tag("blocking-strong")
          Text(NSLocalizedString("blocking-moderate", comment: "")).tag("blocking-moderate")
          Text(NSLocalizedString("blocking-light", comment: "")).tag("blocking-light")
          Text(NSLocalizedString("blocking-none", comment: "")).tag("blocking-none")
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.bottom, 5)
  
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
      .padding(.bottom, 5)
      
      if let cache = cacheBlockingLevel, cache != service.blockingLevel {
        HStack(spacing: 0) {
          Text(NSLocalizedString("blocking-change-text", comment: ""))
            .font(.system(size: 11))
            .foregroundStyle(Color("AlertText"))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
          Spacer()
        }
        .padding(.bottom, 5)
      }
      
      HStack(spacing: 0) {
        Text(NSLocalizedString("Learn More", comment: ""))
          .font(.system(size: 11))
          .foregroundStyle(Color("Point"))
          .onTapGesture {
            browser.newTab(URL(string: "https://github.com/opacity-browser/tracker-blocking")!)
          }
        Spacer()
      }
    }
    .frame(width: 220)
    .padding(.horizontal, 20)
    .padding(.top, 15)
    .padding(.bottom, 15)
    .background(GeometryReader { geometry in
      Color("DialogBG")
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
