//
//  SwiftUIView.swift
//  Opacity
//
//  Created by Falsy on 3/25/24.
//

import SwiftUI

struct SearchAutoCompleteVisitItemNSView: NSViewRepresentable {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var visitHistoryGroup: VisitHistoryGroup
  var isActive: Bool
  
  func makeNSView(context: Context) -> NSView {
    let containerView = StopPropagationNSView()
    let hostingView = NSHostingView(rootView: SearchAutoCompleteVisitItem(browser: browser, tab: tab, visitHistoryGroup: visitHistoryGroup, isActive: isActive))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    return containerView
  }
    
  func updateNSView(_ nsView: NSView, context: Context) {
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<SearchAutoCompleteVisitItem> {
        hostingView.rootView = SearchAutoCompleteVisitItem(browser: browser, tab: tab, visitHistoryGroup: visitHistoryGroup, isActive: isActive)
        hostingView.layout()
      }
    }
  }
}
