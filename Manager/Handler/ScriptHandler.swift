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
  var opacityScriptHandler: OpacityScriptHandler
  
  init(tab: Tab) {
    self.tab = tab
    self.opacityScriptHandler = OpacityScriptHandler(tab: tab)
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? [String: String] {
      
      let scriptName = messageBody["name"] ?? ""
      if let webView = message.webView, let currentURL = webView.url, currentURL.scheme == "opacity" {
        opacityScriptHandler.messages(name: scriptName, value: messageBody["value"])
      }
      
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
            if !domainNotification.isDenied {
              let scriptValue = value ?? ""
              guard let jsonData = scriptValue.data(using: .utf8) else { return }
              do {
                let data = try JSONDecoder().decode(NotificationValue.self, from: jsonData)
                let title = data.title
                let body = data.options?.body
                self.showNotification(title: title, body: body)
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
  
  
  // Notification
  func requestNotificationPermission() {
    self.checkNotificationAuthorization { enabled in
      if let host = self.tab.originURL.host, enabled == true {
        let rawType = DomainPermissionType.notification.rawValue
        let descriptor = FetchDescriptor<DomainPermission>(
          predicate: #Predicate { $0.domain == host && $0.permission == rawType }
        )

        do {
          guard let _ = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first else {
            withAnimation {
              self.tab.isNotificationDialogIcon = true
            }
            return
          }
        } catch {
          print("Model Container Error")
        }
      } else {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if granted {
            DispatchQueue.main.async {
              self.showNotification(
                title: NSLocalizedString("Notification Permissions", comment: ""),
                body: NSLocalizedString("Notification permission granted.", comment: "")
              )
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
  
  func showNotification(title: String, body: String? = nil) {
    let content = UNMutableNotificationContent()
    content.title = title
    
    if let paramBody = body {
      content.body = paramBody
    }
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
  }
}
