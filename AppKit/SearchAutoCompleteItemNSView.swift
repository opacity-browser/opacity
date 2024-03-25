//
//  StopPropagationWrapNSView.swift
//  Opacity
//
//  Created by Falsy on 3/23/24.
//

import SwiftUI

class StopPropagationNSView: NSView {
  override func resetCursorRects() {
    super.resetCursorRects()
    self.addCursorRect(self.bounds, cursor: .arrow)
  }
}

struct SearchAutoCompleteItemNSView: NSViewRepresentable {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var searchHistoryGroup: SearchHistoryGroup
  var isActive: Bool
  
  func makeNSView(context: Context) -> NSView {
    let containerView = StopPropagationNSView()
    let hostingView = NSHostingView(rootView: SearchAutoCompleteItem(browser: browser, tab: tab, searchHistoryGroup: searchHistoryGroup, isActive: isActive))
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
      if let hostingView = subview as? NSHostingView<SearchAutoCompleteItem> {
        hostingView.rootView = SearchAutoCompleteItem(browser: browser, tab: tab, searchHistoryGroup: searchHistoryGroup, isActive: isActive)
        hostingView.layout()
      }
    }
  }
}
