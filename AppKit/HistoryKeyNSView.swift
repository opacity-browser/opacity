//
//  BackKeyButton.swift
//  FriedEgg
//
//  Created by Falsy on 2/17/24.
//
import SwiftUI

struct HistoryKeyNSView<Content: View>: NSViewRepresentable {
  let content: Content
  var clickAction: () -> Void
  var longPressAction: () -> Void
  
  func makeNSView(context: Context) -> HistoryKeyButtonNSView<Content> {
    let hostingView = HistoryKeyButtonNSView(rootView: content)
    hostingView.clickAction = clickAction
    hostingView.longPressAction = longPressAction
    
    return hostingView
  }
  
  func updateNSView(_ nsView: HistoryKeyButtonNSView<Content>, context: Context) {
    nsView.rootView = content
  }
}

class HistoryKeyButtonNSView<Content: View>: NSHostingView<Content> {
  var clickAction: (() -> Void)?
  var longPressAction: (() -> Void)?
  private var clickStartTime: Date?
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    clickStartTime = Date()
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    guard let clickStartTime = clickStartTime else { return }
    
    let clickDuration = Date().timeIntervalSince(clickStartTime)
    if clickDuration < 0.5 {
      clickAction?()
    } else {
      longPressAction?()
    }
  }
}
