//
//  ScriptHandler.swift
//  Opacity
//
//  Created by Falsy on 2/21/24.
//

import SwiftUI
import WebKit
import SwiftData
import UserNotifications

struct NotificationOptions: Codable {
  var body: String
}

struct NotificationValue: Codable {
  var title: String
  var options: NotificationOptions?
}

class ScriptHandler: NSObject, WKScriptMessageHandler {
  @ObservedObject var tab: Tab
  
  init(tab: Tab) {
    self.tab = tab
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? [String: String] {
      let scriptName = messageBody["name"] ?? ""
      
      switch scriptName {
        case "showNotification":
          showNotification(messageBody["value"])
          break
        default: break
      }
      
      if let scriptValue = messageBody["value"] {
        switch scriptName {
          case "hashChange":
            hashChange(scriptValue)
            break
          case "showGeoLocaitonHostPermissionIcon":
            showGeoLocaitonHostPermissionIcon(scriptValue)
            break
          default: break
        }
      } else {
        switch scriptName {
          case "requestWhenInUseAuthorization":
            requestWhenInUseAuthorization()
            break
          case "notificationRequest":
            requestNotificationPermission()
            break
          default: break
        }
      }
    }
  }
  
  func showNotification(_ value: String?) {
    self.checkNotificationAuthorization { enabled in
      if let host = self.tab.originURL.host, enabled == true {
        let rawType = DomainPermissionType.notification.rawValue
        let descriptor = FetchDescriptor<DomainPermission>(
          predicate: #Predicate { $0.domain == host && $0.permission == rawType }
        )
        do {
          if let domainNotification = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
            if domainNotification.isDenied == false {
              let scriptValue = value ?? ""
              guard let jsonData = scriptValue.data(using: .utf8) else { return }
              do {
                let data = try JSONDecoder().decode(NotificationValue.self, from: jsonData)
                let title = data.title
                let body = data.options?.body
                self.actionNotification(title: title, body: body)
              } catch {
                print("JSON Parsing Error : \(error)")
              }
            }
            if self.tab.isNotificationDialogIcon {
              withAnimation {
                self.tab.isNotificationDialogIcon = false
              }
            }
          } else {
            withAnimation {
              self.tab.isNotificationDialogIcon = true
            }
          }
        } catch {
          print("Model Container Error")
        }
      }
    }
  }
  
  func hashChange(_ urlString: String) {
    if let url = URL(string: urlString) {
      DispatchQueue.main.async {
        self.tab.originURL = url
        self.tab.inputURL = StringURL.setInputURL(url)
        self.tab.printURL = StringURL.setPrintURL(url)
      }
    }
  }
  
  func requestWhenInUseAuthorization() {
    DispatchQueue.main.async {
      self.tab.isRequestGeoLocation = true
    }
  }
  
  func showGeoLocaitonHostPermissionIcon(_ value: String) {
    guard let boolValue = Bool(value) else { return }
    DispatchQueue.main.async {
      self.tab.isLocationDialogIconByHost = true
      self.tab.isLocationDialogByHost = boolValue
    }
  }
  
  // Notification
  func requestNotificationPermission() {
    self.checkNotificationAuthorization { enabled in
      guard let webview = self.tab.webview else { return }
      
      if let host = self.tab.originURL.host, enabled == true {
        let rawType = DomainPermissionType.notification.rawValue
        let descriptor = FetchDescriptor<DomainPermission>(
          predicate: #Predicate { $0.domain == host && $0.permission == rawType }
        )
        do {
          if let notiPer = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
            if notiPer.isDenied == false {
              DispatchQueue.main.async {
                webview.evaluateJavaScript("window.resolveNotificationPermission('granted');")
              }
              return
            }
          }
          withAnimation {
            self.tab.isNotificationDialogIcon = true
          }
        } catch {
          print("Model Container Error")
        }
      } else {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if granted {
            withAnimation {
              self.tab.isNotificationDialogIcon = true
            }
          } else {
            DispatchQueue.main.async {
              webview.evaluateJavaScript("window.resolveNotificationPermission('denied');")
            }
          }
        }
      }
    }
  }
  
  func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        switch settings.authorizationStatus {
          case .authorized, .provisional:
            completion(true)
          case .denied:
            completion(false)
          case .notDetermined:
            completion(false)
          @unknown default:
            completion(false)
        }
      }
    }
  }
  
  func actionNotification(title: String, body: String? = nil) {
    let content = UNMutableNotificationContent()
    content.title = title
    
    if let paramBody = body {
      content.body = paramBody
    }
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
  }
}
