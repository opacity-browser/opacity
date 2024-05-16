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
  @Binding var isSiteDialog: Bool
  
  @State var cacheBlockingLevel: String?
  
  init(service: Service, browser: Browser, tab: Tab, isSiteDialog: Binding<Bool>) {
    self.service = service
    self.tab = tab
    self.browser = browser
    self._isSiteDialog = isSiteDialog
    self._cacheBlockingLevel = State(initialValue: service.blockingLevel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if tab.originURL.scheme == "opacity" {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "lock.circle.fill")
              .foregroundColor(Color("Point"))
              .font(.system(size: 26))
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                Text(NSLocalizedString("This connection is secure.", comment: ""))
                Spacer()
              }
              .padding(.bottom, 2)
              HStack(spacing: 0) {
                Text(NSLocalizedString("This is a page provided inside the app.", comment: ""))
                  .opacity(0.6)
                  .font(.system(size: 11))
                Spacer()
              }
            }
            .padding(.leading, 10)
          }
        }
      } else if tab.isValidCertificate == false {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "exclamationmark.triangle.fill")
              .font(.system(size: 20))
              .foregroundColor(Color("AlertText"))
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                Text(NSLocalizedString("This connection is not secure.", comment: ""))
                Spacer()
              }
            }
            .padding(.leading, 10)
          }
        }
      } else {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Image(systemName: "lock.circle.fill")
              .font(.system(size: 26))
              .foregroundColor(Color("Point"))
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                Text(NSLocalizedString("This connection is secure.", comment: ""))
                Spacer()
              }
              .padding(.bottom, 2)
              HStack(spacing: 0) {
                Text(NSLocalizedString("Certificate:", comment: ""))
                  .opacity(0.6)
                  .font(.system(size: 11))
                Text(tab.certificateSummary)
                  .font(.system(size: 11))
                  .padding(.leading, 5)
                Spacer()
              }
            }
            .padding(.leading, 10)
          }
        }
      }
      
      Divider()
        .padding(.vertical, 10)
      
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
      .padding(.bottom, 6)
  
      HStack(spacing: 0) {
        Text(
          service.blockingLevel == "blocking-strong" ?
          NSLocalizedString("blocking-strong-exp", comment: "")
          : service.blockingLevel == "blocking-moderate" ?
          NSLocalizedString("blocking-moderate-exp", comment: "")
          : service.blockingLevel == "blocking-light" ?
          NSLocalizedString("blocking-light-exp", comment: "")
          : NSLocalizedString("blocking-none-exp", comment: "")
        )
        .font(.system(size: 11))
        .foregroundStyle(Color("UIText"))
        .opacity(0.6)
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
      
      Divider()
        .padding(.vertical, 10)
      
      HStack(spacing: 0) {
        Image(systemName: "xserve")
          .frame(maxWidth: 15, maxHeight: 15)
          .foregroundColor(Color("Icon"))
          .offset(y: 1)
        Text("\(NSLocalizedString("Cookie", comment: "")) :")
          .padding(.leading, 8)
        Text("\(tab.cookies.count)")
          .foregroundColor(Color(tab.cookies.count > 0 ? "Point" : "UIText"))
          .opacity(tab.cookies.count > 0 ? 1 : 0.5)
          .padding(.leading, 5)
        Spacer()
      }
      .padding(.bottom, 4)
      
      HStack(spacing: 0) {
        Text("\(tab.localStorage == "{}" && tab.sessionStorage == "{}" ? NSLocalizedString("No web storage data found on the website.", comment: "") : NSLocalizedString("Web storage data is present on the website.", comment: ""))")
          .font(.system(size: 11))
          .foregroundStyle(Color("UIText"))
          .opacity(0.6)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
        Spacer()
      }
      
      HStack(spacing: 0) {
        if tab.localStorage != "{}" || tab.sessionStorage != "{}" || tab.cookies.count > 0 {
          Button {
            DispatchQueue.main.async {
              tab.isClearCookieNStorage = true
              self.isSiteDialog = false
              AppDelegate.shared.refreshTab()
            }
          } label: {
            Text(NSLocalizedString("Clear Cookies and Storage", comment: ""))
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(DialogButtonStyle())
        } else {
          Button {
            
          } label: {
            Text(NSLocalizedString("Clear Cookies and Storage", comment: ""))
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(DialogButtonCancelStyle())
        }
      }
      .padding(.top, 10)
      
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
