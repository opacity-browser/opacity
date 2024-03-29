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
//import AVFoundation

struct NotificationOptions: Codable {
  var body: String
}

struct NotificationValue: Codable {
  var title: String
  var options: NotificationOptions?
}

func dateFromString(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter.date(from: dateString)
}

class ScriptHandler: NSObject, WKScriptMessageHandler, CLLocationManagerDelegate {
  @ObservedObject var tab: Tab
  
  init(tab: Tab) {
    self.tab = tab
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? [String: String] {
      
      let scriptName = messageBody["name"] ?? ""
      
      if let webView = message.webView, let currentURL = webView.url {
        if currentURL.scheme == "opacity" {
          if scriptName == "getBrowerSettings" {
            getBrowerSettings()
          }
          if scriptName == "getSearchEngineList" {
            getSearchEngineList()
          }
          
          if let scriptValue = messageBody["value"] {
            if scriptName == "setSearchEngine" {
              setSearchEngine(scriptValue)
            }
            
            if scriptName == "setBrowserTheme" {
              setBrowserTheme(scriptValue)
            }
            
            if scriptName == "setRetentionPeriod" {
              setRetentionPeriod(scriptValue)
            }
            
            if scriptName == "getSearchHistoryList" {
              getSearchHistoryList(scriptValue)
            }
            
            if scriptName == "getVisitHistoryList" {
              getVisitHistoryList(scriptValue)
            }
            
            if scriptName == "deleteSearchHistory" {
              deleteSearchHistory(scriptValue)
            }
          }
        }
      }
      
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
  
  func deleteSearchHistory(_ historyIds: String) {
    if let jsonData = historyIds.data(using: .utf8) {
      do {
        let decoder = JSONDecoder()
        let deleteHistoryIds = try decoder.decode([String].self, from: jsonData)
        for id in deleteHistoryIds {
          if let uuid = UUID(uuidString: id) {
            SearchManager.deleteSearchHistoryById(uuid)
          }
        }
        let script = """
        window.opacityResponse.deleteSearchHistory({
          data: "success"
        })
      """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      } catch {
        print("Decoding failed: \(error)")
      }
    }
  }
  
  func getSearchHistoryList(_ yearMonth: String) {
    guard let targetDate = dateFromString(yearMonth) else {
      print("Invalid date format")
      let script = """
      window.opacityResponse.getSearchHistoryList({
        data: "parameter error"
      })
    """
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
      return
    }
    
    let descriptor = FetchDescriptor<SearchHistory>()
    
    do {
      let calendar = Calendar.current
      let searchHistoryList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
      
      var firstDateString = ""
      if let firstData = searchHistoryList.first {
        let firstDateYearMonth = calendar.dateComponents([.year, .month], from: firstData.createDate)
        if let fYear = firstDateYearMonth.year, let fMonth = firstDateYearMonth.month {
          let padStartMonth = String(describing: fMonth).count == 2 ? String(describing: fMonth) : "0\(String(describing: fMonth))"
          firstDateString = "\(String(describing: fYear))-\(padStartMonth)"
        }
      }
      let filterHistoryList = searchHistoryList.filter {
        let components = calendar.dateComponents([.year, .month], from: $0.createDate)
        let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)
        return components.year == targetComponents.year && components.month == targetComponents.month
      }
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      var searchHistories: [SearchHistorySettings] = []
      for sh in filterHistoryList {
        searchHistories.append(SearchHistorySettings(id: sh.id, searchText: sh.searchHistoryGroup!.searchText, createDate: dateFormatter.string(from: sh.createDate)))
      }
      let jsonData = try JSONEncoder().encode(searchHistories)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        let script = """
          window.opacityResponse.getSearchHistoryList({
            data: {
              firstDate: "\(firstDateString)",
              list: \(jsonString)
            }
          })
        """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      } else {
        print("getSearchHistoryList JSON pares error")
        let script = """
        window.opacityResponse.getSearchHistoryList({
          data: "error"
        })
      """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } catch {
      print("get search history error")
      let script = """
      window.opacityResponse.getSearchHistoryList({
        data: "error"
      })
    """
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    
    
  }
  
  func getVisitHistoryList(_ scriptValue: String) {
    
  }
  
  func setSearchEngine(_ scriptValue: String) {
    let descriptor = FetchDescriptor<OpacityBrowserSettings>()
    if let searchEngine = SearchEngineList(rawValue: scriptValue) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.searchEngine = searchEngine.rawValue
          let script = """
          window.opacityResponse.setSearchEngine({
            data: "success"
          })
        """
          tab.webview.evaluateJavaScript(script, completionHandler: nil)
        }
      } catch {
        print("Browser search engine setting error")
        let script = """
        window.opacityResponse.getBrowerSettings({
          data: "error"
        })
      """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } else {
      let script = """
      window.opacityResponse.getBrowerSettings({
        data: "parameter error"
      })
    """
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func setBrowserTheme(_ scriptValue: String) {
    let descriptor = FetchDescriptor<OpacityBrowserSettings>()
    if let theme = BrowserThemeList(rawValue: scriptValue) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.theme = theme.rawValue
          let script = """
          window.opacityResponse.setBrowserTheme({
            data: "success"
          })
        """
          tab.webview.evaluateJavaScript(script, completionHandler: nil)
        }
      } catch {
        print("Browser theme setting error")
        let script = """
        window.opacityResponse.setBrowserTheme({
          data: "error"
        })
      """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } else {
      let script = """
      window.opacityResponse.setBrowserTheme({
        data: "parameter error"
      })
    """
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func setRetentionPeriod(_ scriptValue: String) {
    let descriptor = FetchDescriptor<OpacityBrowserSettings>()
    if let period = DataRententionPeriodList(rawValue: scriptValue) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.retentionPeriod = period.rawValue
          let script = """
          window.opacityResponse.setRetentionPeriod({
            data: "success"
          })
        """
          tab.webview.evaluateJavaScript(script, completionHandler: nil)
        }
      } catch {
        print("Browser retention period setting error")
        let script = """
        window.opacityResponse.setRetentionPeriod({
          data: "error"
        })
      """
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } else {
      let script = """
      window.opacityResponse.setRetentionPeriod({
        data: "parameter error"
      })
    """
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func getBrowerSettings() {
    let descriptor = FetchDescriptor<OpacityBrowserSettings>()
    do {
      if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        let script = """
        window.opacityResponse.getBrowerSettings({
          data: {
            searchEngine: "\(browserSettings.searchEngine)",
            theme: "\(browserSettings.theme)",
            retentionPeriod: "\(browserSettings.retentionPeriod)"
          }
        })
      """
        
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } catch {
      print("Error get browser settings")
      let script = """
      window.opacityResponse.getBrowerSettings({
        data: "error"
      })
    """
      
      tab.webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func getSearchEngineList() {
    var searchEngineNameList: [String] = []
    for engine in searchEngineList {
      searchEngineNameList.append(engine.name)
    }
    
    do {
      let jsonData = try JSONEncoder().encode(searchEngineNameList)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        let script = """
        window.opacityResponse.getSearchEngineList({
          data: \(jsonString)
        })
      """
        
        tab.webview.evaluateJavaScript(script, completionHandler: nil)
      }
    } catch {
      print("error parsing message to schema page")
    }
  }
  
//  func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
//    switch AVCaptureDevice.authorizationStatus(for: .video) {
//      case .authorized:
//        completion(true)
//      case .notDetermined:
//        AVCaptureDevice.requestAccess(for: .video) { granted in
//          completion(granted)
//        }
//      default:
//        completion(false)
//    }
//  }
  
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
