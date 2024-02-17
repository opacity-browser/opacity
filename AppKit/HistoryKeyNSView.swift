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
  private var longPressTimer: Timer?
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    longPressTimer?.invalidate()
    // 0.5초 후에 실행될 타이머를 설정합니다.
    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      DispatchQueue.main.async {
        self?.longPressAction?()
      }
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    if longPressTimer != nil && longPressTimer!.isValid {
      longPressTimer?.invalidate()
      clickAction?()
    }
  }
}
