//
//  GeoLocationCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import CoreLocation
import WebKit

class GeoLocationCoordinator: NSObject, @preconcurrency CLLocationManagerDelegate {
  var parent: MainWebView!
  var locationManager: CLLocationManager?
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  func cleanup() {
    locationManager?.stopUpdatingLocation()
    locationManager = nil
  }
  
  func handleLocationUpdates() {
    // Geo Location 전역 권한
    if parent.tab.isRequestGeoLocation {
      DispatchQueue.main.async {
        print("request geo location")
        self.parent.tab.isRequestGeoLocation = false
        self.parent.tab.isLocationDialogIcon = true
        self.parent.tab.isLocationDialog = true
        self.requestGeoLocationPermission()
      }
    }
    
    // Geo Location 업데이트
    if parent.tab.isUpdateLocation {
      DispatchQueue.main.async {
        self.parent.tab.isUpdateLocation = false
        self.requestLocation()
      }
    }
  }
  
  @MainActor func initGeoPositions() {
    guard let webview = parent.tab.webview else { return }
    locationManager = CLLocationManager()
    locationManager!.desiredAccuracy = kCLLocationAccuracyBest
    locationManager!.distanceFilter = kCLDistanceFilterNone
    locationManager!.delegate = self

    switch locationManager!.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      if let url = webview.url,
         let locationPermission = PermissionManager.getLocationPermissionByURL(url: url),
         !locationPermission.isDenied {
        locationManager!.startUpdatingLocation()
      }
    case .denied, .restricted, .notDetermined:
      deniedGeolocation()
    @unknown default:
      break
    }
  }
  
  private func deniedGeolocation() {
    print("deniedGeolocation")
    guard let webview = self.parent.tab.webview else { return }
    let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "requestWhenInUseAuthorization" });
        error({
          code: 1,
          message: 'User Denied Geolocation'
        });
      }
    """
    webview.evaluateJavaScript(script, completionHandler: nil)
  }
  
  private func deniedGeolocationByHost() {
    print("deniedGeolocationByHost")
    guard let locationManager = locationManager, let webview = self.parent.tab.webview else { return }
    
    switch locationManager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
        let script = """
          navigator.geolocation.getCurrentPosition = function(success, error, options) {
            window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "true" });
            error({
              code: 1,
              message: 'User Denied Geolocation'
            });
          }
        """
        webview.evaluateJavaScript(script, completionHandler: nil)
        break
      case .denied, .restricted, .notDetermined:
        deniedGeolocation()
        break
      @unknown default: break
    }
  }
  
  func requestGeoLocationPermission() {
    guard let locationManager = locationManager else { return }
    locationManager.requestWhenInUseAuthorization()
  }
  
  @MainActor func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("didChangeAuthorization")
    DispatchQueue.main.async {
      self.parent.tab.isLocationDialogIconByHost = false
    }
    guard let locationManager = locationManager, let webview = self.parent.tab.webview, let url = webview.url else { return }
    
    switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        DispatchQueue.main.async {
          self.parent.tab.isLocationDialogIcon = false
        }
        if let locationPermition = PermissionManager.getLocationPermissionByURL(url: url) {
          if locationPermition.isDenied == false {
            locationManager.startUpdatingLocation()
            break
          }
        }
        deniedGeolocationByHost()
        break
      case .denied, .restricted:
        print("denied")
        deniedGeolocation()
        break
      default:
        break
    }
  }
  
  @MainActor func requestLocation() {
    guard let locationManager = locationManager else { return }
    print("requestLocation")
    locationManager.stopUpdatingLocation()
    locationManager.startUpdatingLocation()
  }

  @MainActor func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("didUpdateLocations")
    guard let location = locations.first, let webview = self.parent.tab.webview, let url = webview.url, let locationManager = locationManager else { return }
    if let locationPermition = PermissionManager.getLocationPermissionByURL(url: url) {
      if locationPermition.isDenied == false {
        print("allow geo location")
        let script = """
          navigator.geolocation.getCurrentPosition = function(success, error, options) {
            window.webkit.messageHandlers.opacityBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "false" });
            success({
              coords: {
                latitude: \(location.coordinate.latitude),
                longitude: \(location.coordinate.longitude)
              }
            });
          };
          navigator.geolocation.updatePosition(\(location.coordinate.latitude), \(location.coordinate.longitude));
        """

        webview.evaluateJavaScript(script, completionHandler: nil)
        locationManager.stopUpdatingLocation()
        return
      }
    }
    deniedGeolocationByHost()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError")
    guard let webview = self.parent.tab.webview else { return }
    let script = """
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        error({
          code: 1,
          message: 'Location retrieval failed'
        });
      };
    """
    webview.evaluateJavaScript(script, completionHandler: nil)
  }
}
