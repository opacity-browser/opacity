//
//  MainWebViewCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import WebKit

class MainWebViewCoordinator: NSObject {
  var parent: MainWebView!
  
  // 기능별 Coordinator들
  var navigationCoordinator: NavigationCoordinator!
  var downloadCoordinator: DownloadCoordinator!
  var geoLocationCoordinator: GeoLocationCoordinator!
  var sslCertificateCoordinator: SSLCertificateCoordinator!
  var javascriptCoordinator: JavaScriptCoordinator!
  
  init(_ parent: MainWebView) {
    self.parent = parent
    super.init()
    setupCoordinators()
  }
  
  private func setupCoordinators() {
    navigationCoordinator = NavigationCoordinator(parent: parent)
    downloadCoordinator = DownloadCoordinator(parent: parent)
    geoLocationCoordinator = GeoLocationCoordinator(parent: parent)
    sslCertificateCoordinator = SSLCertificateCoordinator(parent: parent)
    javascriptCoordinator = JavaScriptCoordinator(parent: parent)
    
    // Coordinator 간 의존성 설정
    navigationCoordinator.sslCertificateCoordinator = sslCertificateCoordinator
    navigationCoordinator.geoLocationCoordinator = geoLocationCoordinator
  }
  
  deinit {
    navigationCoordinator.cleanup()
    geoLocationCoordinator.cleanup()
  }
}
