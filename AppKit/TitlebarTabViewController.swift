//
//  TitlebarTabViewController.swift
//  Opacity
//
//  Created by Falsy on 10/11/24.
//

import SwiftUI

class TitlebarTabViewController: NSTitlebarAccessoryViewController {
  var service: Service
  var browser: Browser

  init(service: Service, browser: Browser) {
    self.service = service
    self.browser = browser
    super.init(nibName: nil, bundle: nil)
    self.setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    let hostingView = NSHostingView(rootView: TitlebarTabView(service: service, browser: browser))
    self.view = hostingView
  }
}
