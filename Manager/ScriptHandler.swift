//
//  ScriptHandler.swift
//  Opacity
//
//  Created by Falsy on 2/21/24.
//

import SwiftUI
import WebKit
import SwiftData
import CoreLocation
import UserNotifications
import AVFoundation

struct NotificationOptions: Codable {
  var body: String
}

struct NotificationValue: Codable {
  var title: String
  var options: NotificationOptions?
}

class ScriptHandler: NSObject, WKScriptMessageHandler, CLLocationManagerDelegate {
  @ObservedObject var tab: Tab
  
  init(tab: Tab) {
    self.tab = tab
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? [String: String] {
//    if message.name == "opacityBrowser", let messageBody = message.body as? [String: String], let webView = message.webView {
//      guard let currentURL = webView.url else {
//        return
//      }
      
      let scriptName = messageBody["name"] ?? ""
      
      if scriptName == "initGeoPositions" {
        initGeoPositions()
      }
      
      if scriptName == "showLocationSetIcon" {
        showLocationSetIcon()
      }
      
      if scriptName == "notificationRequest" {
        requestNotificationPermission()
      }
      
      if scriptName == "showNotification" {
        self.checkNotificationAuthorization { enabled in
          if let host = self.tab.originURL.host, enabled == true {
            let rawType = DomainPermissionType.notification.rawValue
            let descriptor = FetchDescriptor<DomainPermission>(
              predicate: #Predicate { $0.domain == host && $0.permission == rawType }
            )
            do {
              if let domainNotification = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
                if !domainNotification.isDenied {
                  let scriptValue = messageBody["value"] ?? ""
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
                  self.tab.isNotificationDetailDialog = true
                  self.tab.isNotificationDialogIcon = true
                }
              }
            } catch {
              print("Model Container Error")
            }
          }
        }
      }
    }
  }
  
  func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized:
        completion(true)
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
          completion(granted)
        }
      default:
        completion(false)
    }
  }
  
  func initGeoPositions() {
    switch AppDelegate.shared.locationManager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
        AppDelegate.shared.locationManager.startUpdatingLocation()
        break
      case .denied, .restricted, .notDetermined:
        deniedGeolocation()
        break
      @unknown default: break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        AppDelegate.shared.locationManager.startUpdatingLocation()
        withAnimation {
          tab.isLocationDialogIcon = false
        }
        break
      case .denied, .restricted:
        deniedGeolocation()
        break
      default:
        break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }

    let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        success({
          coords: {
            latitude: \(location.coordinate.latitude),
            longitude: \(location.coordinate.longitude)
          }
        })
      }
    """
    
    tab.webview.evaluateJavaScript(script, completionHandler: nil)
    AppDelegate.shared.locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        error({
          code: 1,
          message: 'Location retrieval failed'
        });
      };
    """
    tab.webview.evaluateJavaScript(script, completionHandler: nil)
  }

  func deniedGeolocation() {
    let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        error({
          code: 1,
          message: 'User Denied Geolocation'
        });
        window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showLocationSetIcon" });
      }
    """
    tab.webview.evaluateJavaScript(script, completionHandler: nil)
  }
  
  func showLocationSetIcon() {
    AppDelegate.shared.locationManager.requestWhenInUseAuthorization()
    withAnimation {
      tab.isLocationDetailDialog = true
      tab.isLocationDialogIcon = true
    }
  }
  
  // notificcation
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
              self.tab.isNotificationDetailDialog = true
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
