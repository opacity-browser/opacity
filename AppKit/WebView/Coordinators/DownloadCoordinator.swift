//
//  DownloadCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import WebKit

class DownloadCoordinator: NSObject, WKDownloadDelegate {
  var parent: MainWebView!
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  // WKDownloadDelegate 메서드들
  func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
    let savePanel = NSSavePanel()
    savePanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    savePanel.nameFieldStringValue = suggestedFilename
    
    savePanel.begin { result in
      if result == .OK {
        completionHandler(savePanel.url)
      } else {
        completionHandler(nil)
      }
    }
  }
  
  func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
    download.delegate = self
  }
  
  func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
    download.delegate = self
  }
  
  func webView(_ webView: WKWebView, download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
    print("Download failed: \(error.localizedDescription)")
  }
  
  func webView(_ webView: WKWebView, downloadDidFinish download: WKDownload) {
    print("Download finished successfully.")
  }
}
