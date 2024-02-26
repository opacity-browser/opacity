//
//  ScriptHandler.swift
//  Opacity
//
//  Created by Falsy on 2/21/24.
//

import SwiftUI
import WebKit
import CoreLocation

struct OpacityScript: Codable {
  var name: String
  var value: String
}

class ScriptHandler: NSObject, WKScriptMessageHandler, CLLocationManagerDelegate {
  
  var targetWebView: WKWebView?
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "opacityBrowser", let messageBody = message.body as? String, let webView = message.webView {
      guard let currentURL = webView.url, let jsonData = messageBody.data(using: .utf8) else {
        return
      }
      
      targetWebView = webView
      
      do {
        let data = try JSONDecoder().decode(OpacityScript.self, from: jsonData)
        
        if currentURL.scheme == "opacity" {
          
        } else {
          
        }
        
        if data.name == "initGeoPositions" {
          initGeoPositions()
        }
        
        if data.name == "showLocationSetIcon" {
          showLocationSetIcon()
        }
        
        if data.name == "checkLocationAuthorization" {
          checkLocationAuthorization()
        }
        
      } catch {
        print("JSON parsing error : \(error)")
      }
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
        AppDelegate.shared.permission.isShowLocationDialog = false
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
    
    if let webView = targetWebView {
      webView.evaluateJavaScript(script, completionHandler: nil)
      AppDelegate.shared.locationManager.stopUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let webView = targetWebView {
      let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        error({
          code: 1,
          message: 'Location retrieval failed'
        });
      };
      """
      webView.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func checkLocationAuthorization() {
    switch AppDelegate.shared.locationManager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
        AppDelegate.shared.locationManager.startUpdatingLocation()
        AppDelegate.shared.permission.isShowLocationDialog = false
        break
      case .denied, .restricted, .notDetermined:
        AppDelegate.shared.locationManager.requestWhenInUseAuthorization()
        showLocationSetIcon()
        break
      @unknown default: break
    }
  }
  

  func deniedGeolocation() {
    if let webView = targetWebView {
      let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        window.webkit.messageHandlers.opacityBrowser.postMessage('{"name": "showLocationSetIcon", "value": ""}');
        error({
          code: 1,
          message: 'User denied Geolocation'
        });
      }
      """
      webView.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  func showLocationSetIcon() {
    withAnimation {
      AppDelegate.shared.permission.isShowLocationDialog = true
    }
  }
  
}
