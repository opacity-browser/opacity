//
//  WebviewView.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

struct WebviewView: View {
  var isAcitive: Bool = false
  @ObservedObject var webviewState: WebviewState
  
  init(isAcitive: Bool, baseURL: String) {
    self.isAcitive = isAcitive
    self.webviewState = WebviewState(webURL: baseURL)
  }
  
  var body: some View {
    if isAcitive {
      Webview(webURL: $webviewState.webURL, inputURL: $webviewState.inputURL, viewURL: $webviewState.viewURL, title: $webviewState.title, goToPage: $webviewState.goToPage, goBack: $webviewState.goBack, goForward: $webviewState.goForward)
    }
  }
}
